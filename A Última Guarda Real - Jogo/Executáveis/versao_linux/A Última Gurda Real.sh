#!/bin/sh
printf '\033c\033]0;%s\a' A Última Guarda Real
base_path="$(dirname "$(realpath "$0")")"
"$base_path/A Última Gurda Real.x86_64" "$@"
