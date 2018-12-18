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

# install PowerPack
mkdir -p wp-content/plugins/wordpress-static-html-plugin/powerpack/

cp wp-content/plugins/wordpress-static-html-plugin/provisioning/deployment_modules/* wp-content/plugins/wordpress-static-html-plugin/powerpack/

# set options for Netlify deploy
$WPCLI wp2static options set selected_deployment_option 'netlify'
$WPCLI wp2static options set netlifySiteID $NETLIFYSITEID
$WPCLI wp2static options set netlifyPersonalAccessToken $NETLIFYACCESSTOKEN
$WPCLI wp2static options set baseUrl https://$NETLIFYSITEID
$WPCLI wp2static options set baseUrl-netlify https://$NETLIFYSITEID
$WPCLI wp2static options set useBasicAuth $USEBASICAUTH
$WPCLI wp2static options set basicAuthUser $BASICAUTHUSER
$WPCLI wp2static options set basicAuthPassword $BASICAUTHPASS

# quick test
$WPCLI wp2static diagnostics

# rm existing theme files
rm -Rf wp-content/themes/diagnostic-theme-for-wp2static

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
