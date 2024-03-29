#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

@test "non-existent class is an error" {
    run --separate-stderr \
        ./create.sh 6 coward/runsaway
    [ "$status" -eq 1 ]
    [ "$stderr" = '** class "coward" level 1 not found' ]

    run --separate-stderr \
        ./create.sh 1 monk/openhand 1 coward/runsaway
    [ "$status" -eq 1 ]
    [ "$stderr" = '** class "coward" level 1 not found' ]
}

@test "non-existent subclass is an error" {
    run --separate-stderr \
        ./create.sh 1 monk/boneless
    [ "$status" -eq 1 ]
    [ "$stderr" = '** subclass "monk/boneless" not found' ]

    run --separate-stderr \
        ./create.sh 6 monk/openhand 1 warlock/noseybonk
    [ "$status" -eq 1 ]
    [ "$stderr" = '** subclass "warlock/noseybonk" not found' ]
}

@test "no subclass is not an error, only a warning" {
    # when starting to put together a character you may not have a subclass
    # in mind, so while not specifying one will result in a character with
    # fewer abilities, that is not considered a broken state

    run --separate-stderr \
        ./create.sh 6 monk
    [ "$status" -eq 0 ]
    [ "$stderr" = '** no subclass specified for class "monk"' ]
    echo "$output" | grep 'Ki-Empowered Strikes'
}

@test "drawing from multiple sources" {
    run --separate-stderr \
        ./create.sh -s srd -s mnf 20 monk/playground
    [ "$status" -eq 0 ]
    echo "$output" | grep 'Storming Flower'

    run --separate-stderr \
        ./create.sh 20 monk/playground
    [ "$status" -eq 1 ]
    [ "$stderr" = '** subclass "monk/playground" not found' ]
}
