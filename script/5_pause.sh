#!/bin/bash
source $(dirname "${BASH_SOURCE[0]}")/base.sh
while getopts :m: OPT; do
    case $OPT in
        m|+m)
            commit_message="$OPTARG"
            ;;
        *)
            echo "usage: ${0##*/} [+-m commit_message]"
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

# operation=$(git-branch-to-operation "${current_branch}")
filename=$(git-branch-to-filename "${current_branch}")


if [[ -z "${commit_message}" ]];then
    commit_message="take a break: ${filename} at $(date)"
fi

git add .
git commit -m "${commit_message}"
git push -u origin "${current_branch}"
git checkout master
