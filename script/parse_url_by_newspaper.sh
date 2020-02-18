#!/bin/bash
PYTHON="python"
set -e
cd $(dirname "${BASH_SOURCE[0]}")
source base.sh

url="$*"

python_env=$(get-cfg-option PythonEnv)
if [[ -d "${python_env}" ]];then
    PYTHON="${python_env}/bin/python"
fi

$PYTHON parse_url_by_newspaper.py "${url}"
