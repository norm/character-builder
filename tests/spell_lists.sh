#!/usr/bin/env bats
bats_require_minimum_version 1.5.0

source spell_slots.sh

# fix me, test at a specific level, not just a list of gained spells
@test "gaining individual spells from subclass" {
    expected="++ Added Oath Spell: Protection From Evil and Good
++ Added Oath Spell: Sanctuary
++ Added Oath Spell: Lesser Restoration
++ Added Oath Spell: Zone of Truth
++ Added Oath Spell: Beacon of Hope
++ Added Oath Spell: Dispel Magic
++ Added Oath Spell: Freedom of Movement
++ Added Oath Spell: Guardian of Faith
++ Added Oath Spell: Commune
++ Added Oath Spell: Flame Strike"

    run --separate-stderr \
        ./create.sh 20 paladin/devotion

    diff -u \
        <(echo "$expected") \
        <(echo "$output" | grep 'Added')
}

@test "gaining a spell list" {
    spellbook="** Add to Spellbook: six Wizard, 1st-level"

    run --separate-stderr \
        ./create.sh 1 wizard

    diff -u \
        <(echo "$spellbook") \
        <(echo "$output" | grep 'Add to Spellbook')
}

@test "multiclass has lower spell availability than slots" {
    # mulitclassing means you can have higher spell slots than the 
    # individual spell levels you are allowed to learn
    added_spells="** Add Spells: two Ranger, 1st-level
** Add Spell: one Ranger, 1st-level
** Add Cantrips: three Wizard
** Add to Spellbook: six Wizard, 1st-level
** Add to Spellbook: two Wizard, 1st-level
** Add to Spellbook: two Wizard, up to 2nd-level"

    run --separate-stderr \
        ./create.sh 4 ranger 3 wizard

    diff -u \
        <(echo "$added_spells") \
        <(echo "$output" | grep 'Add ')
    diff -u \
        <(echo "Spell Slots ${spell_slots[5]}") \
        <(echo "$output" | grep '^Spell Slots')
}

@test "replacing spells at future levels" {
    replace_spells="** Exchange Spell: can replace one Ranger, with another 1st-level
** Exchange Spell: can replace one Ranger, with another 1st-level
** Exchange Spell: can replace one Ranger, with another up to 2nd-level"

    run --separate-stderr \
        ./create.sh 5 ranger

    diff -u \
        <(echo "$replace_spells") \
        <(echo "$output" | grep 'Exchange')
}
