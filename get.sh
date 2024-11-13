#!/bin/bash
# get events from https://www.welcometosheffield.co.uk/visit/what-s-on/all-events
#  and attempt to format as json

URL="https://www.welcometosheffield.co.uk/visit/what-s-on/all-events/"
URL_base="https://www.welcometosheffield.co.uk"
page="${1}"
if [ -z "${page}" ]; then
  echo "use: ./get.sh page"
  echo "please specify page number (1, 2, 3, ...)"
  exit 1
fi

events_html=$(curl -s "${URL}?page=${page}")
results=$(echo "${events_html}" | sed 's/\$/USD/g' | hxnormalize -l 240 -x | hxselect -s '$' "div.search-result")
mapfile -d$ a <<< "${results}"; unset 'a[-1]'
# echo "${#a[@]}" # length
# echo "${a[@]}" # items

all_json='['
sep=''

for event in "${a[@]}"; do
  # name
  name=$(echo "${event}" | hxselect -c "div h3 a")
  # event link
  link=$(echo "${event}" | hxselect -c "div h3 a::attr(href)")
  # description
  description=$(echo "${event}" | hxselect -c "div p" | sed 's/^ * / /g' | tr -d '\n')
	# full date/time
  datetime=$(echo "${event}" | hxselect -c "div.meta small" | sed 's/<[^>]*>//g' | sed 's/^ *//' | sed 's/ *$//')
  # start date
  # replace ".." with "." and "." with ":" (common errors in time)
  start_date=$(echo "${datetime}" | awk -F' ?- ?' '{print $1}' | sed 's/\.\././g' | sed 's/\./:/g')
  if [ ! -z "${start_date}" ]; then
    start_date_unix=$(date --date="${start_date}" +%s)
  else
    start_date_unix=""
  fi
  # end date
  # replace ".." with "." and "." with ":" (common errors in time)
  end_date=$(echo "${datetime}" | awk -F' ?- ?' '{print $2}' | sed 's/\.\././g' | sed 's/\./:/g')
  if [[ "${end_date}" =~ [0-9][0-9]:[0-9][0-9] ]]; then
    maybedate=$(echo "${datetime}" | awk -F' ' '{printf "%s %s %s", $1, $2, $3}')
    end_date="${maybedate} ${end_date}"
  fi
  if [ ! -z "${end_date}" ]; then
    end_date_unix=$(date --date="${end_date}" +%s)
  else
    end_date_unix=""
  fi
  # tags
  tags=$(echo "${event}" | hxselect -s '\n' -c "div.tags small" | sed 's/.*<\/svg> *//g' | sed '/^$/d' | sed 's/^ *//g' | sed 's/ *$//g')

  # create json
  json=$(jq -n --arg url_base "${URL_base}" \
  '{
    "name": $ARGS.positional[0],
    "link": ($url_base + $ARGS.positional[1]),
    "description": $ARGS.positional[2],
		"datetime": $ARGS.positional[3],
    "start_date": $ARGS.positional[4],
    "end_date": $ARGS.positional[5],
    "start_date_unix": $ARGS.positional[6],
    "end_date_unix": $ARGS.positional[7],
    "tags": $ARGS.positional[8] | split("\n")
  }
  ' \
  --args "${name}" "${link}" "${description}" "${datetime}" "${start_date}" "${end_date}" "${start_date_unix}" "${end_date_unix}" "${tags}")
  all_json="${all_json}""${sep}""${json}"
  sep=','
done

all_json="${all_json}]"
# decode html entities
all_json=$(echo "${all_json}" | php -r 'while ($f = fgets(STDIN)){ echo html_entity_decode($f); }')

echo "${all_json}" | jq
