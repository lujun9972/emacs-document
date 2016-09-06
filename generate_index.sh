#!/bin/bash

declare -A catalog_comment_dict
catalog_comment_dict=([calc]="关于Cacl的内容" [elisp-common]="关于elisp的内容" [org-mode]="关于org-mode的内容" [emacs-common]="其他未分类的emacs内容" [raw]="未翻译或者翻译到一半的内容")

function generate_headline()
{
    catalog=$1
    echo "* " $catalog
    echo ${catalog_comment_dict[$catalog]}
    echo 
    generate_links $catalog
}

function generate_links()
{
    catalog=$1
    posts=$(ls -t $catalog)
    old_ifs=$IFS
    IFS="
"
    for post in $posts
    do
        modify_date=$(stat -c "%y" $catalog/$post|cut -d " " -f1)
        echo "[[https://github.com/lujun9972/emacs-document/blob/master/$catalog/$post][$post]]		<$modify_date>"
        echo
    done
    IFS=$old_ifs
}

for catalog in ${!catalog_comment_dict[*]}
do
    generate_headline $catalog
done
