#!/bin/bash
set -e
source base.sh

cd "$(get-project-path)"
if ! git-branch-exist-p "PROJECT";then
    git remote add PROJECT https://github.com/lujun9972/emacs-document.git
fi

git fetch PROJECT
git pull PROJECT master:master
git push origin master:master
