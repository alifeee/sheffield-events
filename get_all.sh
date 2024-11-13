#!/bin/bash
# get all events from https://www.welcometosheffield.co.uk/visit/what-s-on/all-events/
#  by finding total pages and then calling ./get.sh for each page
# saves the output to events.json

date >> /dev/stderr
date
echo  './get_all.sh pages sleep_time'
echo '    pages: total pages to index (default -1 / all)'
echo '    sleep_time: time to sleep between pages (default 1)'

stop_after="${1:--1}"
sleep_time="${2:-1}"
save_to="events.json"

echo "getting all events..."
events_html=$(curl -s "https://www.welcometosheffield.co.uk/visit/what-s-on/all-events/?page=1")
last_page_num=$(echo "${events_html}" | hxnormalize -l 240 -x | hxselect -c "a[data-pagenumber]:nth-last-child(2) span")

echo "getting a total of ${last_page_num} pages..."

mega_json="[]"

for page in `seq 1 "${last_page_num}"`; do
  if [ ! "${stop_after}" == -1 ] && [ "${stop_after}" -lt "${page}" ]; then
    echo "told to stop after ${stop_after} pages... stopping..."
    break
  fi

  echo "getting page ${page}..."
  json_arr=$(./get.sh "${page}")

  items=$(echo "${json_arr}" | jq '.|length')
  echo "  ${items} events found on page ${page}"

  mega_json=$(echo "${mega_json}" | jq --argjson next "${json_arr}" '[.[], $next[]]')

  items=$(echo "${mega_json}" | jq '.|length')
  echo "  total events so far: ${items}"
  if [[ "${sleep_time}" -gt 0 ]]; then
    echo "  sleeping ${sleep_time} secs..."
    sleep "${sleep_time}"
  fi
done

# backup existing copy
date_str=$(date "+%Y-%m-%dT%H%M%S")
backup_fname="backups/${date_str}_${save_to}"
echo "backing up existing file to ${backup_fname}"
cp "${save_to}" "${backup_fname}"
gzip "${backup_fname}"

# save
echo "saving to ${save_to}"
last_edited_unix=$(date -u +%s)
last_edited=$(date -u -d "@${last_edited_unix}" "+%c")
echo "  ...with timestamp ${last_edited} / ${last_edited_unix}"
echo "${mega_json}" | jq -c '{
  "last_edited": $ARGS.positional[0],
  "last_edited_unix": $ARGS.positional[1],
  "events": .
}' --args "${last_edited}" "${last_edited_unix}" > "${save_to}"
echo "saved!"
echo ""
