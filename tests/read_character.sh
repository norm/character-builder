#!/usr/bin/env bats
bats_require_minimum_version 1.5.0


@test "get a single section" {
    expected="Race = Tabaxi
Charisma += 1
Dexterity += 2
Size = Medium
Proficiency += Perception
Proficiency += Stealth"

    run --separate-stderr \
        ./read_character.sh character/shade.txt race

    diff -u <(echo "$expected") <(echo "$output")
}

@test "get a single section case insensitively" {
    expected="Race = Tabaxi
Charisma += 1
Dexterity += 2
Size = Medium
Proficiency += Perception
Proficiency += Stealth"

    run --separate-stderr \
        ./read_character.sh character/shade.txt Race

    diff -u <(echo "$expected") <(echo "$output")
}

@test "empty section is not an error" {
    run --separate-stderr \
        ./read_character.sh character/shade.txt gold

    diff -u <(echo "") <(echo "$output")
}

@test "missing section is not an error" {
    run --separate-stderr \
        ./read_character.sh character/shade.txt muffins

    diff -u <(echo "") <(echo "$output")
}

@test "comments are stripped" {
    expected=""

    run --separate-stderr \
        ./read_character.sh character/shade.txt Equipment

    diff -u <(echo "$expected") <(echo "$output")
}

@test "get any keys within a single section" {
    expected="Hit Points += 6"

    run --separate-stderr \
        ./read_character.sh character/shade.txt "Monk Level 3" "Hit Points"

    diff -u <(echo "$expected") <(echo "$output")
}

@test "get any keys within a single section case insensitively" {
    expected="Hit Points += 6"

    run --separate-stderr \
        ./read_character.sh character/shade.txt "monk level 3" "hit points"

    diff -u <(echo "$expected") <(echo "$output")
}

@test "keys within a single section can return multiple lines" {
    expected="Cantrips += acid-arrow
Cantrips += eldritch-blast
Cantrips += minor-illusion"

    run --separate-stderr \
        ./read_character.sh character/shade.txt "warlock level 1" "Cantrips"

    diff -u <(echo "$expected") <(echo "$output")
}
