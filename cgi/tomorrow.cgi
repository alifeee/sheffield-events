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
tom_evening=$(date -u -d "${this_evening} + 1 day" "+%Y-%m-%dT23:59:59")
this_evening_unix=$(date --date="${this_evening}" +%s)
tom_evening_unix=$(date --date="${tom_evening}" +%s)
tom_events=$(
cat ../events.json | \
  jq -r \
    --arg this_evening_unix "${this_evening_unix}" \
    --arg tom_evening_unix "${tom_evening_unix}" \
    '.events |
    sort_by(.start_date_unix) |
    [.[] | select(.start_date_unix!="" and .start_date_unix > $this_evening_unix and .start_date_unix < $tom_evening_unix)] |
    .[] |
    .datetime + "\n" + .name + "\n" + .description + "\n" + (.tags | join(",")) + "\n" + .link + "\n"'
)

if [ -z "${tom_events}" ]; then
  echo "something went wrong... no events..."
else
  echo "${tom_events}"
fi
