#!/bin/bash

echo "Content-type: text/plain"
echo ""
echo "===== Sheffield Events ====="
echo "by alifeee ~~ alifeee.co.uk ~~"
echo "last updated: "$(cat ../events.json | jq -r '.last_edited')
echo "https://github.com/alifeee/sheffield-events/"
echo "============================"
echo ""

now_unix=$(date -u +%s)
next_ten=$(
cat ../events.json | \
  jq -r --arg now_unix "${now_unix}" \
  '.events |
    sort_by(.start_date_unix) |
    [.[] | select(.start_date_unix!="" and .start_date_unix > $now_unix)] |
    .[:10] |
    .[] |
    .datetime + "\n" + .name + "\n" + .description + "\n" + (.tags | join(",")) + "\n" + .link + "\n"'
)

if [ -z "${next_ten}" ]; then
  echo "something went wrong..."
else
  echo "${next_ten}"
fi
