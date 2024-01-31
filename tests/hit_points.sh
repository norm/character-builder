#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

@test "hit dice and points summary" {
    expected_dice="Hit Dice: 2d6 4d8 "
    expected_minmax="(possible: min=6 max=44)"

    run --separate-stderr \
        ./create.sh 4 monk 2 wizard

    diff -u \
        <(echo "$expected_dice") \
        <(echo "$output" | grep '^Hit Dice')
    diff -u \
        <(echo "$expected_minmax") \
        <(echo "$output" | grep '^Hit Points' | sed -e 's/Hit Points: [^ ]* //')
}

