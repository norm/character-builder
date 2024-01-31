#!/usr/bin/env -S bash -euo pipefail

declare -A class_level
declare -A class_specified
declare -A hit_dice=( ["d6"]=0 ["d8"]=0 ["d10"]=0 ["d12"]=0 )
declare -A hit_points=( ["min"]=0 ["max"]=0 ["rolled"]=0 )
declare -A subclass_seen
declare -A subclass_specified
declare -a proficiency_bonus=(0 +2 +2 +2 +2 +3 +3 +3 +3 +4 +4 +4 +4 +5 +5 +5 +5 +6 +6 +6 +6 +6)
declare -a sources=()
declare -a spell_slots
declare -i overall_level=0
declare -i spell_slot_level=0


function cleanup {
    rm -rf "${level_temp}" "${character_temp}"
}

function slugify {
    echo "$*" \
        | iconv -t ascii//TRANSLIT \
        | sed -r 's/[^a-zA-Z0-9]+/-/g' \
        | sed -r 's/^-+\|-+$//g' \
        | tr A-Z a-z
}

function extract_value {
    echo "$@" | sed -e 's/^.* [^ ]*= *//'
}

function update_hit_points {
    local die=6
    hit_die=$(extract_value "$@")

    [[ "$hit_die" =~ ^[Dd]([1-9][0-9]*)$ ]] \
        && die=${BASH_REMATCH[1]}

    if [[ -v hit_dice["d$die"] ]]; then
        rolled=$(roll_die "$hit_die")
        let hit_dice["d$die"]=hit_dice["$hit_die"]+1
        let hit_points["min"]=hit_points["min"]+1
        let hit_points["max"]=hit_points["max"]+die
        let hit_points["rolled"]=hit_points["rolled"]+rolled
        echo "** Hit Points: rolled $rolled ($hit_die)" \
            > $level_temp/update.hit-points
    else
        >&2 echo "** Unknown Hit Die type: '$hit_die'"
        exit 1
    fi
}

source roll_die.sh
source spell_slots.sh

level_temp="$(mktemp -d "/tmp/dndcreate.level.XXXXX")"
character_temp="$(mktemp -d "/tmp/dndcreate.char.XXXXX")"
trap cleanup EXIT

while [[ "${1:-}" =~ ^- ]]; do
    case "$1" in
        -s)     sources+=("$2")
                shift
                shift
                ;;
        *)      >&2 echo "Unknown option: '$1'"
                exit
                ;;
    esac
done

[ "${#sources[@]}" -eq 0 ] \
    && sources=(srd)

while [ -n "${2:-}" ]; do
    count="$1"
    class="$2"
    shift
    shift

    full_class="$class"
    base_class="$(echo "$class" | cut -d/ -f1)"
    subclass="$(echo "$class" | cut -d/ -f2)"

    class_specified[$base_class]=1
    if [ "$base_class" = "$subclass" ]; then
        >&2 echo "** no subclass specified for class \"${base_class}\""
    else
        subclass_specified[$full_class]=1
    fi

    while [ $count -gt 0 ]; do
        let overall_level=overall_level+1
        let count--

        class="$full_class"
        class_level[$base_class]=$((${class_level[$base_class]:-0} + 1))
        level=${class_level[$base_class]}

        rm -f $level_temp/*

        echo "Proficiency Bonus = ${proficiency_bonus[$overall_level]}" > $level_temp/value.02proficiency

        found=0
        for src in "${sources[@]}"; do
            file="$src/classes/$(printf "$full_class/level_%02d.txt" $level)"
            class="$full_class"
            [ -f "$file" ] \
                && subclass_seen[$full_class]=1

            while [ true ]; do
                file="$src/classes/$(printf "$class/level_%02d.txt" $level)"
                if [ -f "$file" ]; then
                    sed -e 's/^/    /' "$file" >> $level_temp/text
                    echo '' >> $level_temp/text
                    found=1
                fi

                class="$(dirname "$class")"
                [ $class = '.' ] \
                    && break
            done
        done
        if [ $found = 0 ]; then
            >&2 echo "** class \"$base_class\" level ${class_level[$base_class]} not found"
            exit 1
        fi

        # extract set/updated values
        while read value_set; do
            key=$(echo "$value_set" | sed -e 's/ *[^ ]*= *.*//')
            echo "$value_set" > $level_temp/value.$(slugify "$key")
        done < <(sed -ne 's/^    == *//p' $level_temp/text)
        sed -i -e '/^    == .* [^ ]*=/d' $level_temp/text

        while read added; do
            # split '++ Die = d10' into two, leaving '++ More Stuff' alone
            key=$(echo "$added" | sed -e 's/ *[^ ]*= *.*//')
            value=$(echo "$added" | sed -e 's/^.* *[^ ]*= *//')
            # >&2 echo "** key=$key value=$value"
            if [ "$key" != "$value" ]; then
                echo "$value" >> $level_temp/update.$(slugify "$key")
            else
                echo "++ $added" >> $level_temp/update.$(slugify "$key")
            fi
        done < <(sed -ne 's/^    ++ *//p' $level_temp/text)
        sed -i -e '/^    ++ /d' $level_temp/text
        # >&2 echo '--'
        # >&2 ls $level_temp
        # >&2 echo '=='

        while read choice; do
            key=$(echo "$choice" | sed -e 's/:.*$//')
            echo "** $choice" >> $level_temp/choice.$(slugify "$key")
        done < <(sed -ne 's/^    \*\* *//p' $level_temp/text)
        sed -i -e '/^    \*\* /d' $level_temp/text

        # handle spell slot increments
        if [ -f $level_temp/update.spell-slots ]; then
            let spell_slot_level=spell_slot_level+1
        fi
        if [ -f $level_temp/update.spell-slots-single ]; then
            [ ${#class_specified[@]} -eq 1 ] \
                && let spell_slot_level=spell_slot_level+1
        fi
        if [ -f $level_temp/update.spell-slots-multi ]; then
            [ ${#class_specified[@]} -gt 1 ] \
                && let spell_slot_level=spell_slot_level+1
        fi
        rm -f $level_temp/update.spell-slots*

        update_hit_points $(cat $level_temp/update.hit-dice)
        rm $level_temp/update.hit-dice

        (
            echo -n "## Level $overall_level - "
            for f in "${!class_level[@]}"; do
                echo -n "${f^} ${class_level[$f]} "
            done
            echo ''
            echo ''

            cp $level_temp/value.* $character_temp

            for entry in $level_temp/choice.* $level_temp/update.*; do
                [ -e $entry ] \
                    && cat $entry >> $character_temp/text
            done

            cat $level_temp/text
        ) >> $character_temp/text
    done
done

echo -n "Hit Dice: "
for die in "${!hit_dice[@]}"; do
    [ "${hit_dice["$die"]}" -gt 0 ] \
        && echo -n "${hit_dice["$die"]}$die "
done
cat <<EOF

    Spend one (or more) Hit Dice at the end of a Short Rest to heal.
    Roll the die and add your Constitution modifer to regain that
    many HP (up to your max).
EOF

# ${hit_dice["d6"]}d6 ${hit_dice["d8"]}d8 ${hit_dice["d10"]}d10 ${hit_dice["d12"]}d12"
echo "Hit Points: ${hit_points["rolled"]} (possible: min=${hit_points["min"]} max=${hit_points["max"]})"
# echo rolled = ${hit_points["rolled"]}
# echo average = ${hit_points["average"]}
cat <<EOF
    At the end of a Long Rest, regain all lost HP and up to one half 
    of your total Hit Dice rounded down, with a minimum of one die.

EOF

[ $spell_slot_level -gt 0 ] \
    && echo Spell Slots ${spell_slots[$spell_slot_level]}
cat $character_temp/value.*
echo ''
echo ''
cat $character_temp/text

for subclass in "${!subclass_specified[@]}"; do
    if [ -z "${subclass_seen[$subclass]:-}" ]; then
        >&2 echo "** subclass \"$subclass\" not found"
        exit 1
    fi
done
