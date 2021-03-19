#!/bin/bash

lines=()
IFS=$'\n'
while read -r line; do
    lines+=("$line")
done
echo -e "${lines[*]}"
