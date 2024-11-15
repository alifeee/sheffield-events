"""create RSS feed from events
example:
  python feed.py > feed.xml
"""
import sys
import json
from datetime import datetime
from requests.utils import requote_uri
from pybars import Compiler

with open("feed.hbs", 'r') as file:
  template = file.read()

with open("events.json", 'r') as file:
  events = json.load(file)

compiler = Compiler()
template = compiler.compile(template)

def isodate(this, datetime_unix):
  if datetime_unix == '':
    return ''
  return (
    datetime.utcfromtimestamp(int(datetime_unix))
    .strftime('%Y-%m-%dT%H:%M:%SZ')
  )
def urlencode(this, url):
  return requote_uri(url)

helpers = {'isodate': isodate, 'urlencode': urlencode}

output = template(events, helpers=helpers)

print(output)
