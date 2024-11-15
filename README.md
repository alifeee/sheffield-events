# Sheffield Events

Making a machine readable feed of events from <https://www.welcometosheffield.co.uk/visit/what-s-on/all-events/>.

Use these scripts in a Linux terminal.

```bash
# install required packages
sudo apt install html-xml-utils recode
# get events for page 4 of the events page
./get.sh 4
# get all events and save to events.json
./get_all.sh
# get all events up to page 10
./get_all.sh 10
```

## set up on server

```bash
# clone code
mkdir -p /usr/alifeee/sheffield-events
git clone git@github.com:alifeee/sheffield-events.git /usr/alifeee/sheffield-events
cd /usr/alifeee/sheffield-events
sudo apt install html-xml-utils recode

# link to /var/www
mkdir -p /var/www/sheffield
sudo ln -s /usr/alifeee/sheffield-events/events.json /var/www/sheffield/events.json
sudo ln -s /usr/alifeee/sheffield-events/cgi /var/www/sheffield/events

# add nginx config
sudo nano /etc/nginx/nginx.conf
echo '
    location /sheffield/ {
      alias /var/www/sheffield/;
      try_files $uri $uri/ @sheffieldcgi;
      add_header Access-Control-Allow-Origin *;
    }
    location @sheffieldcgi {
      include fastcgi_params;
      fastcgi_param SCRIPT_FILENAME /var/www/$fastcgi_script_name.cgi;
      fastcgi_pass unix:/var/run/fcgiwrap.socket;
    }
'
sudo systemctl restart nginx.service

# set up RSS feed
python3 -m venv env
./env/bin/pip install -r requirements.txt

# set up cron job
crontab -e
# 0 3 * * * (cd /usr/alifeee/sheffield-events/; echo "" > cron.log)
# 0 4 * * * (cd /usr/alifeee/sheffield-events/; ./get_all.sh >> cron.log 2>&1)
# 5 4 * * * (cd /usr/alifeee/sheffield-events/; ./env/bin/python feed.py > cgi/feed.xml)
```
