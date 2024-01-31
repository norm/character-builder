#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

source spell_slots.sh

@test "full caster spell slots" {
    run --separate-stderr \
        ./create.sh 20 wizard

    diff -u \
        <(echo "Spell Slots ${spell_slots[20]}") \
        <(echo "$output" | grep '^Spell Slots')
}

@test "half-caster spell slots" {
    run --separate-stderr \
        ./create.sh 20 paladin

    diff -u \
        <(echo "Spell Slots ${spell_slots[10]}") \
        <(echo "$output" | grep '^Spell Slots')
}

@test "multiclassing 1 level half-caster adds no slots" {
    run --separate-stderr \
        ./create.sh 1 wizard 1 paladin

    diff -u \
        <(echo "Spell Slots ${spell_slots[1]}") \
        <(echo "$output" | grep '^Spell Slots')
}

@test "multiclassing 2 levels half-caster adds slots" {
    run --separate-stderr \
        ./create.sh 1 wizard 2 paladin

    diff -u \
        <(echo "Spell Slots ${spell_slots[2]}") \
        <(echo "$output" | grep '^Spell Slots')
}

@test "multiclassing 3 levels half-caster adds slots, but not too many" {
    # not slots as 3 levels of wizard would have, as half-casters only
    # contribute half a level to multiclassing spell slot calculations
    run --separate-stderr \
        ./create.sh 1 wizard 3 paladin

    diff -u \
        <(echo "Spell Slots ${spell_slots[2]}") \
        <(echo "$output" | grep '^Spell Slots')
}

@test "multiclassing 1 level of caster with non-spellcaster adds no slots" {
    run --separate-stderr \
        ./create.sh 1 wizard 19 monk

    diff -u \
        <(echo "Spell Slots ${spell_slots[1]}") \
        <(echo "$output" | grep '^Spell Slots')
}
