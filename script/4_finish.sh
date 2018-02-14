#!/bin/bash
source $(dirname "${BASH_SOURCE[0]}")/base.sh
while getopts :dm: OPT; do
    case $OPT in
        d|+d)
            delete_branch=1
            ;;
        m|+m)
            commit_message="$OPTARG"
            ;;
        *)
            echo "usage: ${0##*/} [+-d}"
            exit 2
    esac
done
shift $(( OPTIND - 1 ))
OPTIND=1

cd $(get-project-path)
current_branch=$(git-get-current-branch)
if [[ "${current_branch}" == "master" ]];then
    warn "Project is under the master branch! Exiting"
    exit 1
fi

operation=$(git-branch-to-operation "${current_branch}")
filename=$(git-branch-to-filename "${current_branch}")

if [[ "${operation}" == "translate" ]];then
    # 使用reformat.sh格式化
    reformat_flag=$(get-cfg-option AutoReformat)
    if [[ -n "${reformat_flag}" && "${reformat_flag}" != "0" ]];then
        echo "reformat the ${filename}"
        (cd $CFG_PATH;./reformat.sh)
    fi

    # 将文件从sources移动到translated目录
    sources_file_path=$(find ./ -name "${filename}") # 搜索出相对路径
    if [[ "${sources_file_path}" =~ ^\./sources/.+$ ]];then
        translated_file_path="$(echo "${sources_file_path}"|sed 's/sources/translated/')"
        echo git mv "${sources_file_path}" "${translated_file_path}"
        git mv "${sources_file_path}" "${translated_file_path}"
    fi
fi

if [[ -z "${commit_message}" ]];then
    commit_message="${operation} done: ${filename}"
fi

git add .
git commit -m "${commit_message}" && git push -u origin "${current_branch}"
git checkout master
if [[ -n "${delete_branch}" ]];then
    git branch -d "${current_branch}"
fi
