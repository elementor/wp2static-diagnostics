#!/bin/bash
. ./.env

cd $WP2STATICSCRIPTSDIR

# read deploy key and site url from env vars

cd $WPDIR

WPCLI="$(which wp) $WPCMDAPPEND"

# remove previous version, while preserving settings.
$WPCLI plugin deactivate --uninstall wordpress-static-html-plugin

# rm plugin dir if exists
rm -Rf $WPDIR/wp-content/plugins/wp2static

# install latest development version
$WPCLI plugin install https://github.com/leonstafford/wp2static/archive/master.zip

# rename folder for correct plugin slug
mv wp-content/plugins/wp2static wp-content/plugins/wordpress-static-html-plugin

# activate the renamed plugin
$WPCLI plugin activate wordpress-static-html-plugin

# set options for Netlify deploy
$WPCLI wp2static options netlifySiteID $NETLIFYSITEID
$WPCLI wp2static options netlifyPersonalAccessToken $NETLIFYACCESSTOKEN
$WPCLI wp2static options baseUrl https://$NETLIFYSITEID
$WPCLI wp2static options baseUrl-netlify https://$NETLIFYSITEID
$WPCLI wp2static options useBasicAuth $USEBASICAUTH
$WPCLI wp2static options basicAuthUser $BASICAUTHUSER
$WPCLI wp2static options basicAuthPassword $BASICAUTHPASS

# quick test
$WPCLI wp2static diagnostics

# install theme for running diagnostics
$WPCLI theme install https://github.com/leonstafford/diagnostic-theme-for-wp2static/archive/master.zip --activate

# generate an archive
$WPCLI wp2static generate

# pipe generate time into a TXT file and have this loaded by the theme via JS...

# this allows for some general benchmarking/comparison across hosts

# test deploy
$WPCLI wp2static deploy --test

# deploy (to folder "/mystaticsite/" if no existing options set)
$WPCLI wp2static deploy
