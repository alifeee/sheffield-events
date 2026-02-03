#!/bin/bash

echo "Content-type: text/plain"
echo ""
echo "===== Sheffield Events ====="
echo "by alifeee ~~ alifeee.net ~~"
echo "last updated: "$(cat ../events.json | jq -r '.last_edited')
echo "https://github.com/alifeee/sheffield-events/"
echo "============================"
echo ""

now_unix=$(date -u +%s)
this_evening=$(date -u -d "@${now_unix}" "+%Y-%m-%dT23:59:59")
this_evening_unix=$(date -u --date="${this_evening}" +%s)
today_events=$(
cat ../events.json | \
  jq -r \
    --arg now_unix "${now_unix}" \
    --arg this_evening_unix "${this_evening_unix}" \
    '.events |
    sort_by(.start_date_unix) |
    [.[] | select(.start_date_unix!="" and .start_date_unix > $now_unix and .start_date_unix < $this_evening_unix)] |
    .[] |
    .datetime + "\n" + .name + "\n" + .description + "\n" + (.tags | join(",")) + "\n" + .link + "\n"'
)

if [ -z "${today_events}" ]; then
  echo "no events..."
  echo "something went wrong... or it's very late"
else
  echo "${today_events}"
fi
