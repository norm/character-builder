#!/usr/bin/env bash -euo pipefail

overall_level=0
declare -A class_level

while [ -n "${2}" ]; do
    count="$1"
    class="$2"
    shift
    shift

    full_class="$class"
    base_class="$(echo "$class" | cut -d/ -f1)"

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

        found=0
        while [ true ]; do
            file=$(printf "$class/level_%02d.txt" $level)
            if [ -f "$file" ]; then
                sed -e 's/^/    /' "$file"
                echo ''
                found=1
            fi
            class="$(dirname "$class")"

            if [ $class = '.' ]; then
                if [ $found = 0 ]; then
                    >&2 echo "** $full_class level ${class_level[$base_class]}: text not found"
                    exit 1
                fi
                break
            fi
        done
    done
done
