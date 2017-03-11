#!/bin/bash

declare -A catalog_comment_dict
catalog_comment_dict=([calc]="关于Cacl的内容" [dired]="文件管理" [advertisement]="别看广告,看疗效" [elisp-common]="关于elisp的内容" [org-mode]="关于org-mode的内容" [emacs-common]="其他未分类的emacs内容" [raw]="未翻译或者翻译到一半的内容" [reddit]="reddit好问题" [Eshell]="Eshell之野望")

catalogs=$(for catalog in ${!catalog_comment_dict[*]};do
               echo $catalog
           done |sort)

function get_contributors()
{
    echo "* Contributors"
    echo "感谢GitHub以及:"
    # for contributor in $(git log --pretty='%an<%ae>'|grep -viEw 'darksun|lujun9972' |sort|uniq)
    # do
    #     echo "+ $contributor"
    # done
    git shortlog --summary --email |grep -viEw 'darksun|lujun9972'|cut -f2|sed -e 's/^/+ /'
}

function generate_headline()
{
    local catalog=$1
    echo "* " $catalog
    echo ${catalog_comment_dict[$catalog]}
    echo 
    generate_links $catalog |sort -t "<" -k2 -r
}

function generate_links()
{
    local catalog=$1
    posts=$(ls -t $catalog)
    old_ifs=$IFS
    IFS="
"
    for post in $posts
    do
        modify_date=$(git log --date=short --pretty=format:"%cd" -n 1 $catalog/$post) # 去除日期前的空格
        if [[ -n "$modify_date" ]];then # 没有修改日期的文件没有纳入仓库中,不予统计
            echo "+ [[https://github.com/lujun9972/emacs-document/blob/master/$catalog/$post][$post]]		<$modify_date>"
        fi
    done
    IFS=$old_ifs
}

get_contributors

for catalog in $catalogs
do
    generate_headline $catalog
done
