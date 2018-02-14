#!/bin/bash
url="$*"
source=$(w3m -dump_source https://pymotw.com/3/unittest/|sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
title=$(echo "${source}" |grep -i '<title>'|sed 's/<[^>]*>//g')
echo '{}'|jq '{"title":$title,"content":$source}' --arg title "$title" --arg source "$source"
