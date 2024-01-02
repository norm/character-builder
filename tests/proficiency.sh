#!/usr/bin/env bats

@test "proficiency starts plus two" {
    result=$(
        bash create.sh 1 monk \
            | grep Proficiency
    )
    [ "$result" = 'Proficiency Bonus = +2' ]
}
@test "proficiency tops out plus six" {
    result=$(
        bash create.sh 20 monk \
            | grep Proficiency \
            | tail -1
    )
    [ "$result" = 'Proficiency Bonus = +6' ]
}
@test "proficiency not related to class" {
    result=$(
        bash create.sh 1 monk 5 warlock \
            | grep Proficiency \
            | tail -1
    )
    [ "$result" = 'Proficiency Bonus = +3' ]
}
