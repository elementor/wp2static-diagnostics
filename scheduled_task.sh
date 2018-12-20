#!/bin/bash

# generate a static site copy and deploy to Netlify
function build_and_deploy {
  # exit 1 # DEBUG

  # change to this script's dir
  cd "${0%/*}"

  # read deploy key and site url from env vars
  . ./.env

  # run WP-CLI cmds from WordPress root
  cd $WPDIR

  WPCLI="$WPCLIPATH"

  # rm existing theme files
  rm -Rf wp-content/themes/diagnostic-theme-for-wp2static

  # install theme for running diagnostics (needed before plugin)
  $WPCLI theme install https://github.com/leonstafford/diagnostic-theme-for-wp2static/archive/master.zip --activate

  # remove previous version, while preserving settings.
  # TODO: returns error code 1 if fails, need to avoid that or CRON chokes
  #$WPCLI plugin deactivate --uninstall wordpress-static-html-plugin

  # rm plugin dir if exists
  rm -Rf $WPDIR/wp-content/plugins/wp2static
  rm -Rf $WPDIR/wp-content/plugins/wordpress-static-html-plugin

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
  $WPCLI wp2static options set baseUrl https://$NETLIFYSITEID.netlify.com
  $WPCLI wp2static options set baseUrl-netlify https://$NETLIFYSITEID.netlify.com
  $WPCLI wp2static options set useBasicAuth $USEBASICAUTH
  $WPCLI wp2static options set basicAuthUser $BASICAUTHUSER
  $WPCLI wp2static options set basicAuthPassword $BASICAUTHPASS

  # quick test
  $WPCLI wp2static diagnostics

  # generate an archive
  DURATION=$($WPCLI wp2static generate | tail -n 1 | cut -d' ' -f 7)

  # pipe date and export duration into TXT file and load  by the theme via JS...
  echo "$(date +%s),$DURATION" >> exports_data.txt

  # copy exports_data into latest archive zip
  LATEST_ARCHIVE=$(cat wp-content/uploads/WP-STATIC-CURRENT-ARCHIVE.txt)

  zip -u ${LATEST_ARCHIVE%?}.zip exports_data.txt

  # deploy (to folder "/mystaticsite/" if no existing options set)
  $WPCLI wp2static deploy

  # save last_commit after a successful deploy
  curl -i "https://api.github.com/repos/leonstafford/wp2static/commits/HEAD" 2>/dev/null | grep sha | head -n 1 > $HOME/last_commit

}

# determine if script needs to run

# look for a lastknowncommit file in $HOME
if [ ! -f $HOME/last_commit ]; then
    echo "No commit history found, saving latest commit & running build and deploy"

    build_and_deploy
    exit 0
else
  # get latest public commit in WP2Static repo
  curl -i "https://api.github.com/repos/leonstafford/wp2static/commits/HEAD" 2>/dev/null | grep sha | head -n 1 > $HOME/latest_commit

  # compare the 2, if there's a change, overwrite 
  # lastcommit with latest commit and run the script
  DIFF=$(diff $HOME/last_commit $HOME/latest_commit) 

  if [ "$DIFF" != "" ] 
  then
      echo "A new commit has been detected, running script"
      mv $HOME/latest_commit $HOME/last_commit 
      build_and_deploy
      exit 0
  else
      echo "No new commits since last check. Audi 5000"
  fi
fi



