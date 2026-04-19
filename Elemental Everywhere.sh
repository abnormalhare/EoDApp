#!/bin/sh
printf '\033c\033]0;%s\a' Elemental Everywhere
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Elemental Everywhere.x86_64" "$@"
