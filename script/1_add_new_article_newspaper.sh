#!/bin/bash
set -e
source $(dirname "${BASH_SOURCE[0]}")/base.sh

url="$*"
[[ -z "${url}" ]] && read -r -p "please input the URL:" url
baseurl=$(get-domain-from-url "${url}")
if url-blocked-p "${baseurl}";then
    warn "${baseurl} is blocked!"
    exit 1
fi

# 搜索类似的文章
echo "search simliar articles..."
if search-similar-articles "${url}";then
    continue-p "found similar articles"
fi

parse_url_script="parse_url_by_${0##*_}"
response=$(${CFG_PATH}/${parse_url_script} "${url}")

# 获取title
if [[ -z "${title}" ]];then
    title=$(echo ${response} |jq -r .title)
    [[ "${title}" == "null" || -z "${title}" ]] && read -r -p "please input the Title:" title
fi

# 获取content
content=$(echo ${response} |jq -r .content)

echo title= "${title}"
echo content= "${content}"

# 生成新文章
source_path="../raw"
filename=$(date-title-to-filename "${title}")
source_file="${source_path}"/"${filename}"

# 使用trap删掉临时文件
function cleanup_temp {
    [ -e "${source_file}" ] && rm --force "${source_file}"
    exit 0
}
trap cleanup_temp  SIGHUP SIGINT SIGPIPE SIGTERM


cat > "${source_file}"<<EOF
#+TITLE: ${title}
#+URL: ${url}
#+AUTHOR: $(get-github-user)
#+TAGS: raw
#+DATE: [$(date)]
#+LANGUAGE:  zh-CN
#+OPTIONS:  H:6 num:nil toc:t \n:nil ::t |:t ^:nil -:nil f:t *:t <:nil
EOF

if [[ -n "${content}" || "${content}" == "null" ]];then
    pandoc --reference-links --reference-location=document -f html-native_divs-native_spans -t org --wrap=preserve --strip-comments --no-highlight --indented-code-classes=python ${url} >>  "${source_file}" 

else
    eval $(get-browser) "${url}"
fi


eval "$(get-editor) '${source_file}'"
read -p "保存好原稿后,按回车继续" continue

# 新建branch 并推送新文章
filename=$(basename "${source_file}")
new_branch="$(filename-to-branch add "${filename}")"
git branch "${new_branch}" master
git checkout "${new_branch}"
git add "${article_directory}/${filename}"
git commit -m "选题: ${title}" && git push -u origin "${new_branch}"
