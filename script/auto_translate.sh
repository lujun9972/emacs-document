#!/bin/bash
set -e
source base.sh
export PATH=$PATH:${CFG_PATH}
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
    dest_file="${source_file}.autotranslated"
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

        if [[ "${position}" != "属性" && "${line^^}" =~ ^[[:blank:]]*':PROPERTIES:' ]];then
            position="属性"
            continue
        fi

        if [[ "${position}" == "属性" && "${line^^}" =~ ^[[:blank:]]*':END:' ]];then
            position="正文"
            continue
        fi

        if [[ "${line}" =~ ^\*+[[:blank:]] ]];then # 标题不翻译
                continue
        fi


        if [[ "${position}" != "引用" && "${line^^}" =~ ^[[:blank:]]*'#+BEGIN_EXAMPLE' ]];then
                position="引用"
                continue
        fi

        if [[ "${position}" == "引用" && "${line^^}" =~ ^[[:blank:]]*'#+END_EXAMPLE' ]];then
            position="正文"
            continue
        fi

        if [[ "${position}" != "引用" && "${line^^}" =~ ^[[:blank:]]*'#+BEGIN_SRC' ]];then
                position="引用"
                continue
        fi

        if [[ "${position}" == "引用" && "${line^^}" =~ ^[[:blank:]]*'#+END_SRC' ]];then
            position="正文"
            continue
        fi

        if [[ "${position}" == "正文" && "${line}" == *[a-zA-Z]*  ]];then
            printf "翻译:"
            fanyi.sh  "${line}" # 至少包含一个英文字母才需要翻译
        fi
    done < <(cat "${article}")
}

do_translate "${source_file}"|tee "${dest_file}"
