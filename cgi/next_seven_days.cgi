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
this_evening=$(date -u -d "@${now_unix}" "+%Y-%m-%dT23:59:59")
next_week=$(date -u "+7 days")
next_week_evening=$(date -u -d "${next_week}" "+%Y-%m-%dT23:59:59")
next_week_evening_unix=$(date --date="${next_week_evening}" +%s)
events=$(
cat ../events.json | \
  jq -r \
    --arg now_unix "${now_unix}" \
    --arg next_week_evening_unix "${next_week_evening_unix}" \
    '.events |
    sort_by(.start_date_unix) |
    [.[] | select((.start_date_unix!="") and (.start_date_unix > $now_unix) and (.start_date_unix < $next_week_evening_unix))] |
    .[] |
    .datetime + "\n" + .name + "\n" + .description + "\n" + (.tags | join(",")) + "\n" + .link + "\n"'
)

if [ -z "${events}" ]; then
  echo "something went wrong..."
else
  echo "${events}"
fi
