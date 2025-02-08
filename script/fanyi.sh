#!/usr/bin/bash

set -o errexit
content="$*"
# BASEURL="https://api.deepseek.com"
# MODEL="deepseek-chat"
# messages="[{\"role\": \"system\", \"content\": \"你是一个好用的翻译助手，请将我的非中文文字翻译成中文。\"},
# {\"role\": \"user\", \"content\": \"${content}\"}
# ]"

# PROMPT='你是一个好用的翻译助手，请将我的英文文字翻译成中文，非英文不用翻译，翻译后请保持org-mode格式不变!".'
PROMPT='你是一个好用的翻译助手，请将我的非中文文字翻译成中文!注意翻译时保持源文本格式不变，另外不要做无畏的演绎！".'
BASEURL="https://open.bigmodel.cn/api/paas/v4"
MODEL="glm-4v-flash"
messages=$(jq -n --arg content "${content}" --arg prompt "$PROMPT" '[{"role": "assistant", "content": $prompt},
{"role": "user", "content": [{"type": "text", "text": $content}]}
]')
selector=".choices[0].message.content| @text"
# echo $messages
curl -s "${BASEURL}/chat/completions" \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${LLMKEY}" \
  -d "{
        \"model\": \"${MODEL}\",
        \"messages\": ${messages},
        \"stream\": false
      }" |jq -r "${selector}"
