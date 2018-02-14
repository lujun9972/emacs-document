#!/bin/bash
set -e
source $(dirname "${BASH_SOURCE[0]}")/base.sh
# 搜索可以翻译的文件
declare -a files
sources_dir="$(get-project-path)/raw"
file="$*"


cd "$(dirname "${file}")"
filename=$(basename "${file}")
new_branch="$(filename-to-branch translate "${filename}")"
git branch "${new_branch}" master
git checkout "${new_branch}"
# 迁移到process目录
git mv  "${filename}" "../processing"
git add "../processing/${filename}"
git_user=$(get-github-user)
git commit -m "translating by ${git_user}"
git push -u origin "${new_branch}"

# 打开要翻译的文章
eval "$(get-editor) '${filename}'"
