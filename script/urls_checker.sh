#!/bin/bash
function Usage
{
    cat <<EOF
Usage:
${0##*/} [+-lcs} [--] ARGS...
${0##*/} -l sources/published/translated   -- 列出尚未翻译/已翻译/已发布的url
${0##*/} -c sources/published/translated  sources/published/translated -- 检查是否有重复的urls
与-s选项连用则表示进入strict mode，这个mode下不会去掉url中?后面的参数
EOF
}
if [[ $# -le 1 ]];then
    Usage
    exit 2
fi
strict=0
while getopts :lcs OPT; do
    case $OPT in
        l|+l)
            operation="list"
            ;;
        c|+c)
            operation="comm"
            ;;
        s|+s)
            strict=1
            ;;
        *)
            echo "usage: "
            exit 2
    esac
done
shift $(( OPTIND - 1 ))
OPTIND=1
directory1=$1
directory2=$2

set -e
source $(dirname "${BASH_SOURCE[0]}")/base.sh
cd "$(get-project-path)"

if [[ ${strict} -eq 0 ]];then
    function list_urls()
    {
        git grep -E "^#\+URL:.+$" $1 |sed "s/^.\+#+URL:[[:space:]]*//"|sed "s/[[:space:]]*$//" |sed "s/?.\+$//"|sort
    }
else
    function list_urls()
    {

        git grep -E "^#\+URL:.+$" $1 |sed "s/^.\+#+URL:[[:space:]]*//"|sed "s/[[:space:]]*$//" |sort
    }
fi


if [[ "${operation}" == "list" ]];then
    list_urls "${directory1}"
elif [[ "${operation}" == "comm" ]];then
    comm -12 <(list_urls "${directory1}") <(list_urls "${directory2}")
else
    warn "不支持的操作:${operation}"
fi
