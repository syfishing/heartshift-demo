#!/bin/sh
printf '\033c\033]0;%s\a' heartshift-demo
base_path="$(dirname "$(realpath "$0")")"
"$base_path/heartshift-demo.x86_64" "$@"
