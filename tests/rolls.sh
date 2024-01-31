#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

@test "default roll is 1d6" {
    for i in $(seq 1 100); do
        run --separate-stderr \
            ./roll_die.sh

        [ "$status" -eq 0 ]
        [ -n "$output" -a "$output" -ge 1 -a "$output" -lt 7 ]
    done
}

@test "invalid notation is an error" {
    run --separate-stderr \
        ./roll_die.sh fridge

    [ "$status" -eq 1 ]
    [ -z "$output" ]
    [ "$stderr" = "Invalid dice notation: 'fridge'" ]
}

@test "explicit 1d6" {
    for i in $(seq 1 100); do
        run --separate-stderr \
            ./roll_die.sh 1d6

        [ "$status" -eq 0 ]
        [ -n "$output" -a "$output" -ge 1 -a "$output" -lt 7 ]
    done
}

@test "5d6" {
    for i in $(seq 1 100); do
        run --separate-stderr \
            ./roll_die.sh 5d6

        [ "$status" -eq 0 ]
        [ -n "$output" -a "$output" -ge 5 -a "$output" -lt 30 ]
    done
}

@test "multiple arguments" {
    for i in $(seq 1 100); do
        run --separate-stderr \
            ./roll_die.sh 5d6 10d10

        [ "$status" -eq 0 ]
        [ -n "$output" ]
        sixes="${lines[0]}"
        [ -n "$sixes" -a "$sixes" -ge 5 -a "$sixes" -lt 30 ]
        tens="${lines[1]}"
        [ -n "$tens" -a "$tens" -ge 10 -a "$tens" -lt 101 ]
    done
}
