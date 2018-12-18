# WP2Static Diagnostics Scripts

For diagnostics and benchmarking WP2Static on various hosting platforms.

Runs on every new commit to [https://github.com/leonstafford/wp2static](https://github.com/leonstafford/wp2static)

# Current hosts

|Deployed site|Provider|   |   |   |
|---|---|---|---|---|
|[wp2static-vultr1.netlify.com](https://wp2static-vultr1.netlify.com)|[Vultr](https://www.vultr.com/)|   |   |   |
|   |   |   |   |   |
|   |   |   |   |   |


# Adding additional servers checklist

 - basic auth
 - disable pwd login
 - clone this repo to root (via https):
 - `git clone https://github.com/leonstafford/wp2static-diagnostics.git`
 - create .env file in project `cp .env-SAMPLE .env`, with following:
 - `WPDIR`
 - `WP2STATICSCRIPTSDIR`
 - `NETLIFYSITEID`
 - `NETLIFYACCESSTOKEN`
 - allow web user to run WP-CLI
