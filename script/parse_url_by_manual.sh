#!/bin/bash
url="$*"
function trim()
{
    echo "$*" |sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}
source=$(curl "$url")
title=$(trim $(echo "${source}" |grep -i '<title>'|sed 's$.*<title>$$i;s$</title>.*$$i'))
echo '{}'|jq '{"title":$title,"content":$source}' --arg title "$title" --arg source "$source"
