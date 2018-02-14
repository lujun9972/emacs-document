#!/bin/bash
# 使用全角中文
source $(dirname "${BASH_SOURCE[0]}")/base.sh
if [[ $# -eq 0 ]];then
    cd "$(get-lctt-path)"
    filepath=$(git-current-branch-to-file-path)
else
    filepath="$*"
fi

sed -i '1,/----------------------------------------------------------------/ {
/```/,/```/!{
# 中英文之间加上空格,英文可能被符号扩起来了
s/\([[:upper:][:lower:]][[:punct:]]*\)\([^[:upper:][:lower:][:blank:][:cntrl:][:punct:][:digit:]]\)/\1 \2/g;
s/\([^[:upper:][:lower:][:blank:][:cntrl:][:punct:][:digit:]]\)\([[:punct:]]*[[:upper:][:lower:]]\)/\1 \2/g;
# 中文和数字之间加上空格,数字也可能被符号扩起来了
s/\([[:digit:]][[:punct:]]*\)\([^[:upper:][:lower:][:blank:][:cntrl:][:punct:][:digit:]]\)/\1 \2/g;
s/\([^[:upper:][:lower:][:blank:][:cntrl:][:punct:][:digit:]]\)\([[:punct:]]*[[:digit:]]\)/\1 \2/g;
s/,/，/g;                       # 任何,都被替换
s/?/？/g;                       # 任何?都被替换
s/!$/！/g;                      # !在尾部则可被替换
s/!\([^[]\)/！\1/g;             # !不跟[则可以被替换，但是由于图片的格式是![,因此不能被替换
# 由于.用户划分域名(www.baidu.com)和版本号(3.4.1)，因此不能被随意替换
s/\.$/。/g;                     # .在行尾也能被替换
s/\([^[:space:]]\)\.\([^[:upper:][:lower:][:digit:]]\)/\1。\2/g; # .前不是空格且后面不是英文或数字也能被替换
# 由于:用户划分域名(http://www.baidu.com)，因此也不能被随意替换
s/:$/：/g;                     # :在行尾也能被替换
s/:\([^/]\)/：\1/g;             # :后面不跟/则能被替换
s/:\([^[:upper:][:lower:][:digit:][:punct:]]\)/：\1/g; # :后不是英文或数字或标点也能被替换
# 全角标点与其他字符之间不加空格
s/[[:blank:]]*\(：\|，\|？\|！\|。\)/\1/g;
s/\(：\|，\|？\|！\|。\)[[:blank:]]*/\1/g;
}}' "${filepath}"
