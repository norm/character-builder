#!/usr/bin/env bash -euo pipefail

overall_level=0
declare -A class_level
declare -A subclass_specified
declare -A subclass_seen
declare -a proficiency_bonus=(0 +2 +2 +2 +2 +3 +3 +3 +3 +4 +4 +4 +4 +5 +5 +5 +5 +6 +6 +6 +6 +6)
declare -a sources


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

        echo "Proficiency Bonus = ${proficiency_bonus[$overall_level]}"
        echo ''

        found=0
        for src in "${sources[@]}"; do
            file="$src/classes/$(printf "$full_class/level_%02d.txt" $level)"
            class="$full_class"
            [ -f "$file" ] \
                && subclass_seen[$full_class]=1

            while [ true ]; do
                file="$src/classes/$(printf "$class/level_%02d.txt" $level)"
                if [ -f "$file" ]; then
                    sed -e 's/^/    /' "$file"
                    echo ''
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
    done
done

for subclass in "${!subclass_specified[@]}"; do
    if [ -z "${subclass_seen[$subclass]}" ]; then
        >&2 echo "** subclass \"$subclass\" not found"
        exit 1
    fi
done
