#!/bin/bash
url="$*"
source=$(w3m -dump_source "$url")
title=$(echo "${source}" |grep -i '<title>'|sed 's/<[^>]*>//g'|sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
echo '{}'|jq '{"title":$title,"content":$source}' --arg title "$title" --arg source "$source"
