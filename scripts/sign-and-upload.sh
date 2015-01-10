if [[ "$TRAVIS_BRANCH" != "develop" ]]; then
  echo "Testing on a branch other than develop. No deployment will be done."
  exit 0
fi


PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
OUTPUTDIR="$PWD/build/Release-iphoneos"

if [ ! -f PROVISIONING_PROFILE ]; then
    echo "***************************"
    echo "Provisioning not found!"
    echo "***************************"
fi
xcrun -log -sdk iphoneos PackageApplication "$OUTPUTDIR/$APP_NAME.app" -o "$OUTPUTDIR/$APP_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

zip -r -9 "$OUTPUTDIR/$APP_NAME.app.dSYM.zip" "$OUTPUTDIR/$APP_NAME.app.dSYM"

RELEASE_DATE=`date '+%Y-%m-%d %H:%M:%S'`
RELEASE_NOTES="Build: $TRAVIS_BUILD_NUMBER\nUploaded: $RELEASE_DATE"

if [ ! -z "$TESTFLIGHT_TEAM_TOKEN" ] && [ ! -z "$TESTFLIGHT_API_TOKEN" ]; then
  echo ""
  echo "***************************"
  echo "* Uploading to Testflight *"
  echo "***************************"
  curl http://testflightapp.com/api/builds.json \
    -F file="@$OUTPUTDIR/$APP_NAME.ipa" \
    -F dsym="@$OUTPUTDIR/$APP_NAME.app.dSYM.zip" \
    -F api_token="$TESTFLIGHT_API_TOKEN" \
    -F team_token="$TESTFLIGHT_TEAM_TOKEN" \
    -F distribution_lists='Internal' \
    -F notes="$RELEASE_NOTES"
fi