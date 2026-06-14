set positional-arguments

default:
    @just --list

format:
    alejandra .
    stylua init.lua lua/
