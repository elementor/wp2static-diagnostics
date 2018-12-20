# WP2Static Diagnostics Scripts

For diagnostics and benchmarking WP2Static on various hosting platforms.

Runs on every new commit to [https://github.com/leonstafford/wp2static](https://github.com/leonstafford/wp2static)

# Current hosts

|Deployed site|Provider|Theme|Plugins|Notes|
|---|---|---|---|---|
|[wp2static-vultr1.netlify.com](https://wp2static-vultr1.netlify.com)|[Vultr](https://www.vultr.com/)|WP2Static Diagnostics|Akismet<br/>Hello Dolly<br/>WP2Static|   |
|   |   |   |   |   |
|   |   |   |   |   |


# Adding additional servers checklist

 - basic auth
 - disable pwd login
 - clone this repo to root (via https):
 - `git clone https://github.com/leonstafford/wp2static-diagnostics.git`
 - cp `.env` file to `.env-SAMPLE` and set variables
 - allow web user to run WP-CLI
 - set mail, ie postfix to send to local user

# Scheduling the detect and build task

 - `crontab -e`
```
# check for WP2Static updates every n mins
*/1 * * * * /bin/bash /root/wp2static-diagnostics/scheduled_task.sh
```

 - `/bin/bash /path/to/scheduled_task.sh`

# Monitor on host

` tail -f /var/log/syslog /root/cronlog.log /var/mail/root`

# In action

[![asciicast](https://asciinema.org/a/217395.svg)](https://asciinema.org/a/217395)
