
NOTIFY() {
    
    [[ $(type -f terminal-notifier) ]] && { terminal-notifier -title "$TARGET_NAME" -message "$1"; } || say "$1"
    [[ $# > 2 ]] && exit $2
}

MAC_FW () {
    
  WRAPPED_NAME="${PROJECT_NAME}.framework"
  FW_DIR="${USER_LIBRARY_DIR}/Frameworks"
  [[ -z "$FW_DIR/$WRAPPED_NAME" ]] && NOTIFY "product isnt there"

  if ! /usr/bin/diff -x 'Modules' -rq "${BUILT_PRODUCTS_DIR}/$WRAPPED_NAME" "$FW_DIR/$WRAPPER_NAME"
  then NOTIFY "skipping install" 0
  fi
  
  /usr/bin/rsync --delete --recursive --times -v --progress  --links "${BUILT_PRODUCTS_DIR}/$WRAPPED_NAME" "$FW_DIR"
  
  NOTIFY "RSYNC'd ${WRAPPED_NAME}" 0
  #  /usr/bin/rsync --recursive --times -v --progress --links --stats "$PROD" "$USER_FWS"
}

GO_DEVICE_APP() {  logger "Installing $TARGET_NAME on iPhone"

	exit $(/xbin/installapp "$BUILT_PRODUCTS_DIR/$WRAPPER_NAME")    \
            && say "installed ${TARGET_NAME/#AtoZ/} on device"    \
            || say "${TARGET_NAME/#AtoZ/} install failed"	
}
GO_SIM_FWK() {
    
  mkdir -p "${SIM_FWKS=/Users/$(whoami)/Library/Frameworks-Simulator}"
  cp -fr "${CODESIGNING_FOLDER_PATH}" "$SIM_FWKS"
  NOTIFY "installed into Simulator Frameworks" 0
}

[[ ! -x "${EXE=${CODESIGNING_FOLDER_PATH}/${TARGET_NAME}}" ]] && NOTIFY "Hmm, missing executable:$EXE"  36
[[ ! $(otool -L "${EXE:-/dev/null}") ]]                       && NOTIFY "otool verify failed!"          37

[[ "${EFFECTIVE_PLATFORM_NAME}" =~ "mac"       ]]   && MAC_FW        || \
[[          $WRAPPER_EXTENSION  != "framework" ]]   && GO_DEVICE_APP || \
[[    $EFFECTIVE_PLATFORM_NAME  =~ "simulator"      &&   
         "${WRAPPER_EXTENSION}" == "framework" ]]   && GO_SIM_FWK    || \
[[    $EFFECTIVE_PLATFORM_NAME  != "-iphoneos" ]]   && NOTIFY "dunno what to do" 0

     HASH=$(md5 -q "$EXE")
  HASHKEY="$TARGET_NAME${EFFECTIVE_PLATFORM_NAME:--$PLATFORM_NAME}"
SAVEDHASH="$(defaults read com.mrgray.AtoZ $HASHKEY)" 2> /dev/null; # check saved hash

[[ "$HASH" == "$SAVEDHASH" ]] && NOTIFY "$TARGET_NAME hashes match!" 0

ssh -q 6 -C "[[ -d /Library/Frameworks/$WRAPPER_NAME ]]" && NOTIFY "Skipping $TARGET_NAME Hashes match, files exist, aborting" 0

NOTIFY "Installing TARGET_NAME Framework onto device."

scp -r  "$CODESIGNING_FOLDER_PATH" 6:/Library/Frameworks 2>&1 | head -n1 | sed 's/ssh://;s/6\.local.*//g'

[[ $? == 0 ]] && NOTIFY "installed ${TARGET_NAME/#AtoZ/} framework on device" 
              || NOTIFY "copy to device failed for ${TARGET_NAME/#AtoZ/}." 58
}

#buildPlist="${PRODUCT_NAME}-Info.plist"
## Get the existing buildVersion and buildNumber values from the buildPlist
#buildVersion=$(/usr/libexec/PlistBuddy -c "Print CFBuildVersion" $buildPlist)
#buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBuildNumber" $buildPlist)
#buildDate=$(date "+%Y%m%d.%H%M%S")

## Increment the buildNumber
#buildNumber=$(($buildNumber + 1))

## Set the version numbers in the buildPlist
#/usr/libexec/PlistBuddy -c "Set :CFBuildNumber $buildNumber" $buildPlist
#/usr/libexec/PlistBuddy -c "Set :CFBuildDate $buildDate" $buildPlist
#/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildVersion.$buildNumber" $buildPlist
#/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $buildVersion.$buildNumber" $buildPlist
#/usr/libexec/PlistBuddy -c "Set :CFBundleLongVersionString $buildVersion.$buildNumber.$buildDate" $buildPlist
#+%s)
#/usr/libexec/PlistBuddy -c "Set :__TIMESTAMP__ $(date)" "$INFOPLIST_FILE"
# set -e
# set -o pipefail
#terminal-notifier -title "$TARGET_NAME" -message "no diff"
#  --checksum  --sparse
#  logger "rsync cmd is \"$RCMD\"" eval "$RCMD"
#  defaults write "com.mrgray.AtoZ" "$HASHKEY" $HASH