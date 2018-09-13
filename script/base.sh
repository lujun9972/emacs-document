#!/bin/echo Warinng: this library should be sourced!
CFG_PATH=$(cd $(dirname "${BASH_SOURCE[0]}")&&pwd)
function get-cfg-option ()
{
    option="$@"
    egrep "^${option}=" ${CFG_PATH}/project.cfg |cut -d "=" -f 2-
}

function get-project-path()
{
    dirname "${CFG_PATH}"
}


function file-translating-p ()
{
    local file="$*"
    head "$file" |grep -E -i "translat|fanyi|翻译" >/dev/null 2>&1
}

function file-translating-by-me-p()
{
    local file="$*"
    head "$file" |grep -E -i "translat|fanyi|翻译" |grep $(get-github-user) >/dev/null 2>&1
}

function search-similar-articles ()
{
    if [[ $# -eq 0 ]];then
        cat <<EOF
该函数可用于检查是否存在重复的文章。
Usage: $0 文件名称
EOF
        return 1
    fi

    url="$*"
    clean_url=${url%%\?*}
    (cd $(get-project-path) && git grep "#+URL: *${clean_url}")
}

function command-exist-p()
{
    command -v "$@" >/dev/null 2>/dev/null
}

function continue-p()
{ read -p "$*,CONTINUE? [y/n]" CONT
  case $CONT in
      [nN]*)
          exit 1
          ;;
  esac
}

function get-github-user()
{
    local user=$(get-cfg-option GithubUser)
    if [[ -z ${user} ]];then
        user=$(git config --list |grep "user.name="|awk -F "=" '{print $2}')
    fi
    echo ${user}
}

function get-browser()
{
    local browser=$(get-cfg-option Browser)
    if [[ -z ${browser} ]];then
        browser="firefox"
    fi
    echo ${browser}
}

function get-editor()
{
    local editor=$(get-cfg-option Editor)
    if [[ -z ${editor} ]];then
        editor="vi"
    fi
    echo ${editor}
}

function git-branch-exist-p()
{
    local branch="$*"
    git branch -a |grep -E "${branch}" >/dev/null
}

function get-domain-from-url ()
{
    local url="$*"
    echo "${url}"|sed 's#^\(https*://[^/]*\).*$#\1#'
}

function url-blocked-p()
{
    local url="$*"
    local blocked_domain=$(get-cfg-option BlockedDomains)
    local domain=$(get-domain-from-url "$url")
    # echo "$blocked_domain" |grep "$domain" >/dev/null
    [[ "${blocked_domain}" == *"${domain}"* ]] # 可以用 == 来匹配
}

function warn ()
{
    echo "$*" >&2
}

function git-get-current-branch ()
{
    git branch |grep "*" |cut -d " " -f2
}

function filename-to-branch ()
{
    local operation=$1
    shift
    local title="$*"
    local code=$(echo "${title}"|base64 -w 0)
    echo "${operation}-${code}"
}

# 解析branch中包含的操作类型 add/translate
function git-branch-to-operation()
{
    local branch="$*"
    local operation=$(echo "${branch}"|cut -d "-" -f1)
    echo "${operation}"
}

# 解析branch中包含的文件名信息
function git-branch-to-filename()
{
    local branch="$*"
    local code=$(echo "${branch}" |cut -d "-" -f2)
    echo "${code}"|base64 -d
}

# 返回branch参数中正在编辑文件的 *绝对路径*
function git-branch-to-file-path()
{
    local branch="$*"
    local filename=$(git-branch-to-filename "${branch}")
    find "$(get-project-path)" -name "${filename}"
}

# 根据当前branch得到当前编辑的文件 *绝对路径*
function git-current-branch-to-file-path()
{
    # 在子shell中操作，不要修改原work directory
    (
    cd "$(get-project-path)"
    local branch=$(git-get-current-branch)
    git-branch-to-file-path "${branch}"
    )
}

# 根据时间以及文章title转换成标准的文件名
function date-title-to-filename()
{
    title=$(echo "$*" |sed 's/[^][0-9a-zA-Z.,()‘_ -]/-/g'|sed 's/-*$//') # 特殊字符换成-号,最后的-去掉
    echo "${title}.org"
}

# 为文件加上翻译中的标记
function mark-file-as-tranlating()
{
    local filename="$*"
    local git_user=$(get-github-user)
    sed -i "1i translating by ${git_user}" "${filename}"
    sed -i "/-------------------------------/,$ s/译者ID/${git_user}/g" "${filename}"
}

# 根据url和author获取作者链接
function get-author-link()
{
    url="$1"
    domain=$(get-domain-from-url "${url}")
    author="$2"
    # 在子shell中操作，不要影响原shell的工作目录
    (
        cd $(get-project-path)
        # 选择最多的url作为author link
        git grep -iEc "#+URL: *${domain}|\[${author}\]"|grep ":2$"|cut -d":" -f1|xargs -I{} grep "\[a\]:" '{}' |sort |uniq -c |sort -n |tail -n 1 |cut -d":" -f2-
        # git grep -il "${domain}"|xargs -I{} grep -il "\[${author}\]" '{}' |tail -n 1 |xargs -I{} grep '\[a\]:' '{}' |cut -d ":" -f2-
     )
}

# 判断文件的类型是tech还是talk
function guess-article-type()
{
    local article="$*"
    if grep '```' "${article}" >/dev/null;then
        echo "tech"
    else
        echo "talk"
    fi
}
