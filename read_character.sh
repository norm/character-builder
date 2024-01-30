#!/usr/bin/env -S bash -euo pipefail

function read_character {
    local character="$1"
    local section="$2"
    local keys="${3:-}"

    sed -n \
        -e '/^ *#/d' \
        -e "/^--- $section/I,/^---/{ /^---/d; /$keys /Ip; }" \
            $character
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    read_character "$@"
fi
