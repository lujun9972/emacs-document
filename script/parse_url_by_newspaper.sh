#!/bin/bash
set -e
cd $(dirname "${BASH_SOURCE[0]}")
source base.sh

url="$*"

python_env=$(get-cfg-option PythonEnv)
if [[ -d "${python_env}" ]];then
    source "${python_env}/bin/activate"
fi

python parse_url_by_newspaper.py "${url}"
