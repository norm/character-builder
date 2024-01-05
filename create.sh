#!/usr/bin/env bash -euo pipefail

overall_level=0
declare -A class_level
declare -A class_specified
declare -A subclass_specified
declare -A subclass_seen
declare -a proficiency_bonus=(0 +2 +2 +2 +2 +3 +3 +3 +3 +4 +4 +4 +4 +5 +5 +5 +5 +6 +6 +6 +6 +6)
declare -a sources
declare -i spell_slot_level=0
declare -a spell_slots=(''
    '1:[ ][ ]'
    '1:[ ][ ][ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ] 7:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ] 7:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ] 7:[ ] 8:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ] 7:[ ] 8:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ] 7:[ ] 8:[ ] 9:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ][ ] 6:[ ] 7:[ ] 8:[ ] 9:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ][ ] 6:[ ][ ] 7:[ ] 8:[ ] 9:[ ]'
    '1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ][ ] 6:[ ][ ] 7:[ ][ ] 8:[ ] 9:[ ]'
)
level_temp="$(mktemp -d "/tmp/dndcreate.XXXXX")"


function slugify {
    echo "$*" \
        | iconv -t ascii//TRANSLIT \
        | sed -r 's/[^a-zA-Z0-9]+/-/g' \
        | sed -r 's/^-+\|-+$//g' \
        | tr A-Z a-z
}


while [[ "$1" =~ ^- ]]; do
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


while [ -n "${2}" ]; do
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
        let overall_level++
        let count--

        class="$full_class"
        class_level[$base_class]=$((${class_level[$base_class]} + 1))
        level=${class_level[$base_class]}

        echo -n "## Level $overall_level - "
        for f in "${!class_level[@]}"; do
            echo -n "${f^} ${class_level[$f]} "
        done
        echo ''
        echo ''

        cp /dev/null $level_temp/text
        echo "Proficiency Bonus = ${proficiency_bonus[$overall_level]}" > $level_temp/value.0proficiency

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

        # extract values from the text so they can be parsed
        grep '^    [^ ].* = ' $level_temp/text \
            | sed -e 's/^    //' \
            | sort \
                > $level_temp/new_values

        # remove spell slot increments
        if grep --quiet '^    Spell Slots ++' $level_temp/text; then
            let spell_slot_level++
        fi
        if grep --quiet '^    Spell Slots Single ++' $level_temp/text; then
            [ ${#class_specified[@]} -eq 1 ] \
                && let spell_slot_level++
        fi
        if grep --quiet '^    Spell Slots Multi ++' $level_temp/text; then
            [ ${#class_specified[@]} -gt 1 ] \
                && let spell_slot_level++
        fi

        while read value; do
            value_file="$level_temp/value.$(slugify "${value%% =*}")"
            echo "$value" > $value_file
        done < $level_temp/new_values

        # values appear first, then the text
        cat $level_temp/value.*
        [ $spell_slot_level -gt 0 ] \
            && echo Spell Slots ${spell_slots[$spell_slot_level]}

        echo ''

        grep -v \
            -e '^    [^ ].* = ' \
            -e '^    Spell Slots.* ++' \
            $level_temp/text
        echo ''
    done
done

for subclass in "${!subclass_specified[@]}"; do
    if [ -z "${subclass_seen[$subclass]}" ]; then
        >&2 echo "** subclass \"$subclass\" not found"
        exit 1
    fi
done
