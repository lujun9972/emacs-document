#!/bin/bash
set -e
source base.sh
export PATH=$PATH:${CFG_PATH}/youdao.sh
while getopts :rf: OPT; do
    case $OPT in
        r|+r)
            replace_flag="True"
            ;;
        f|+f)
            source_file="$OPTARG"
            ;;
        *)
            echo "usage: ${0##*/} [+-rf ARG} [--] ARGS..."
            exit 2
    esac
done
shift $(( OPTIND - 1 ))
OPTIND=1

if [[ "${replace_flag}" == "True" ]];then
    dest_file="${source_file}"
else
    dest_file="/dev/tty"
fi

function do_translate()
{
    article="$*"
    position="元数据"            # 其他可能值包括 "正文","引用","结尾"
    while read line
    do
        echo "${line}"
        if [[ "${position}" == "元数据" ]];then
            if [[ "${line}" == \#+* ]];then
                continue
            else
                position="正文"
            fi
        fi

        if [[ "${position}" != "引用" && "${line}" == '#+BEGIN_EXAMPLE' ]];then
                position="引用"
                continue
        fi

        if [[ "${position}" == "引用" && "${line}" == '#+END_EXAMPLE' ]];then
            position="正文"
            continue
        fi

        if [[ "${position}" == "正文" && "${line}" == *[a-zA-Z]*  ]];then
            youdao.sh "${line}" # 至少包含一个英文字母才需要翻译
        fi
    done < <(cat "${article}")
}

translated_content="$(do_translate "${source_file}")"
echo "${translated_content}" > "${dest_file}"
