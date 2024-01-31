#!/usr/bin/env -S bash -euo pipefail

function roll_die {
    local roll rolls sides i total=0
    roll=$(echo "${1:-1d6}" | tr '[:upper:]' '[:lower:]')

    if [[ "$roll" =~ ^([0-9]*)d([1-9][0-9]*)$ ]]; then
        rolls="${BASH_REMATCH[1]}"
        sides="${BASH_REMATCH[2]}"
    else
        >&2 echo "Invalid dice notation: '$1'"
        exit 1
    fi

    for ((i=1; i<=${rolls:-1}; i++)); do
        result=$((1 + RANDOM % ${sides:-6}))
        let total=total+result
    done
    echo "$total"
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    while
        roll_die "${1:-}"
        shift
        [ -n "${1:-}" ]
    do true; done
fi
