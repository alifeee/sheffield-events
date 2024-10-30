# Sheffield Events

Making a machine readable feed of events from <https://www.welcometosheffield.co.uk/visit/what-s-on/all-events/>.

Use these scripts in a Linux terminal.

```bash
# install required packages
sudo apt get html-xml-utils recode
# get events for page 4 of the events page
./get.sh 4
# get all events and save to events.json
./get_all.sh
# get all events up to page 10
./get_all.sh 10
```
