D&D 5e character builder
========================

Create a text file that describes only the available features of a D&D
character at a given level, including when multiclassing.


Usage:

```
bash create.sh [number-of-levels] [class/subclass] ...

# start your perfect warlock
bash create.sh 1 warlock/hexblade

# multiclass her a little
bash create.sh 3 warlock/hexblade 3 sorcerer/shadow 2 warlock/hexblade

# or, see what a full straight class gives you
bash create.sh 20 cleric/order
```


## Requirements

* ensure that running `bash --version` in your shell reports at least
  version 4.0, or you'll need to find a more modern bash (looking at you,
  macOS).
* install `bats-core` (at least v1.5) if you want to run/edit/add tests


## Populating a new class

Create `level_01.txt` through `level_20.txt`.


### Populating subclass

There is no need to create level files when the subclass has no changes at
that level, with the exception that each subclass must have a `level_01.txt`
file, even if it is empty.


## Running tests

Either `make test` to run all tests, or `bats tests/___.sh` to run one (or
more) individual test files.


## Licence

This repository is MIT licenced at the top to indicate the code and
any documentation I have written.

Class descriptions are available under CC-BY-4.0.

This work includes material taken from
the Systems Reference Document 5.1 (“SRD 5.1”)
by Wizards of the Coast LLC and available at
https://dnd.wizards.com/resources/systems-reference-document.
The SRD 5.1 is licensed under
the Creative Commons Attribution 4.0 International License
available at https://creativecommons.org/licenses/by/4.0/legalcode.
