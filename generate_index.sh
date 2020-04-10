#!/bin/bash

declare -A catalog_comment_dict
catalog_comment_dict=([calc]="关于Calc的内容" [dired]="文件管理" [advertisement]="别看广告,看疗效" [elisp-common]="关于elisp的内容" [org-mode]="关于org-mode的内容" [eww]="Emacs看片，指日可待" [emacs-common]="其他未分类的emacs内容" [raw]="未翻译的内容,欢迎大家领取" [reddit]="reddit好问题" [Eshell]="Eshell之野望" [processing]="正在翻译的内容,别人的东西可不要抢哦~" [email]="使用Emacs收发邮件" [fun]="娱乐至上" [spellcheck]="你的错误，由我来发现")

catalogs=$(for catalog in ${!catalog_comment_dict[*]};do
               echo $catalog
           done |sort)

function get_contributors()
{
    echo "* Contributors"
    echo "感谢GitHub以及:"
    # git log --pretty='%an<%ae>'|grep -viEw 'darksun|lujun9972' |sort|uniq|sed -e 's/^/+ /'
    git shortlog --summary --email HEAD |grep -viEw 'darksun|lujun9972'|cut -f2|sed -e 's/^/+ /'
    echo ""
    echo "感谢大家的热情参与,也欢迎更多的志愿者参与翻译,参与的方法可以参见 [[https://github.com/lujun9972/emacs-document/wiki/%E7%BF%BB%E8%AF%91%E6%8F%90%E7%A4%BA][Emacs-document Wiki]]"
}

function generate_headline()
{
    local catalog="$*"
    echo "* $catalog"
    echo ${catalog_comment_dict[$catalog]}
    echo 
    generate_links $catalog |sort -t "<" -k2 -r
}

function generate_links()
{
    local catalog=$1
    if [[ ! -d $catalog ]];then
        mkdir -p $catalog
    fi
    posts=$(find $catalog -maxdepth 1 -type f)
    old_ifs=$IFS
    IFS="
"
    for post in $posts
    do
        modify_date=$(git log --date=short --pretty=format:"%cd" -n 1 $post) # 去除日期前的空格
        if [[ -n "$modify_date" ]];then # 没有修改日期的文件没有纳入仓库中,不予统计
            postname=$(basename $post)
            url="$(grep '^#+URL:' ${post} |sed 's/^#+URL: *//')"
            echo "+ [[https://github.com/lujun9972/emacs-document/blob/master/$post][$postname]]		<$modify_date>	 [[${url}][原文地址]]"
        fi
    done|sort -k 2
    IFS=$old_ifs
}

get_contributors

for catalog in $catalogs
do
    generate_headline $catalog
done
