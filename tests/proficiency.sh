#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

@test "proficiency starts plus two" {
    expected='Proficiency Bonus = +2'

    run --separate-stderr \
        ./create.sh 1 monk

    diff -u \
        <(echo "$expected") \
        <(echo "$output" | grep '^Proficiency')
}
@test "proficiency tops out plus six" {
    expected='Proficiency Bonus = +6'

    run --separate-stderr \
        ./create.sh 20 monk

    diff -u \
        <(echo "$expected") \
        <(echo "$output" | grep '^Proficiency')
}
@test "proficiency not related to class" {
    expected='Proficiency Bonus = +3'

    run --separate-stderr \
        ./create.sh 1 monk 5 warlock

    diff -u \
        <(echo "$expected") \
        <(echo "$output" | grep '^Proficiency')
}
