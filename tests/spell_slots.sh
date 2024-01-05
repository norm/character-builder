#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

@test "full caster spell slots" {
    expected="Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ] 7:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ] 7:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ] 7:[ ] 8:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ] 7:[ ] 8:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ] 6:[ ] 7:[ ] 8:[ ] 9:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ][ ] 6:[ ] 7:[ ] 8:[ ] 9:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ][ ] 6:[ ][ ] 7:[ ] 8:[ ] 9:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ][ ] 6:[ ][ ] 7:[ ][ ] 8:[ ] 9:[ ]"

    run --separate-stderr \
        bash create.sh 20 wizard

    diff -u <(echo "$expected") <(echo "$output" | grep 'Spell Slots')
}

@test "half-caster spell slots" {
    expected="Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ][ ]
Spell Slots 1:[ ][ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ]
Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ][ ] 3:[ ][ ][ ] 4:[ ][ ][ ] 5:[ ][ ]"

    run --separate-stderr \
        bash create.sh 20 paladin

    diff -u <(echo "$expected") <(echo "$output" | grep 'Spell Slots')
}

@test "multiclassing 1 level half-caster adds no slots" {
    expected="Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]"

    run --separate-stderr \
        bash create.sh 1 wizard 1 paladin

    diff -u <(echo "$expected") <(echo "$output" | grep 'Spell Slots')
}

@test "multiclassing 2 levels half-caster adds slots" {
    expected="Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ][ ]"

    run --separate-stderr \
        bash create.sh 1 wizard 2 paladin

    diff -u <(echo "$expected") <(echo "$output" | grep 'Spell Slots')
}

@test "multiclassing 3 levels half-caster adds slots, but not too many" {
    expected="Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ][ ]
Spell Slots 1:[ ][ ][ ]"

    # not "Spell Slots 1:[ ][ ][ ][ ] 2:[ ][ ]" as 3 levels of wizard would
    # have, as half-casters only contribute half a level to multiclassing
    # spell slot calculations

    run --separate-stderr \
        bash create.sh 1 wizard 3 paladin

    diff -u <(echo "$expected") <(echo "$output" | grep 'Spell Slots')
}

@test "multiclassing 2 levels caster with non-spellcaster adds no slots" {
    expected="Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]
Spell Slots 1:[ ][ ]"

    run --separate-stderr \
        bash create.sh 1 wizard 19 monk

    diff -u <(echo "$expected") <(echo "$output" | grep 'Spell Slots')
}
