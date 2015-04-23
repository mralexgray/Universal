#!/bin/bash


NOTIFY() {
    terminal-notifier -title "$TARGET_NAME" -message "$1"
    if [ $# > 2 ]; then exit $2; fi
}

[[ -z "${EXE=${CODESIGNING_FOLDER_PATH}/${TARGET_NAME}}" ]] && say whatthefuck

[[ ! -x "$EXE" ]] && NOTIFY "WTF" 122
if ! otool -L "${EXE:-/dev/null}"; then NOTIFY "otool verify failed!" 99; fi


GO_MAC () {
  
  [[ -z "${USER_LIBRARY_DIR}/Frameworks/${WRAPPER_NAME}" ]] && NOTIFY "product isnt there" 88

  if ! /usr/bin/diff -x 'Modules' -rq "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" \
                                   "${USER_LIBRARY_DIR}/Frameworks/${WRAPPER_NAME}"
  then NOTIFY "skipping install" 0
  fi
  
  /usr/bin/rsync --delete --recursive --times -v --progress  --links "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" "${USER_LIBRARY_DIR}/Frameworks"
  #  /usr/bin/rsync --recursive --times -v --progress --links --stats "$PROD" "$USER_FWS"
  NOTIFY "RSYNC'd ${WRAPPER_NAME} ${USER_LIBRARY_DIR}/Frameworks" 0
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

[[ "${EFFECTIVE_PLATFORM_NAME}" =~ "mac" ]]   && GO_MAC        || \
[[ $WRAPPER_EXTENSION != "framework" ]]       && GO_DEVICE_APP || \
[[ $EFFECTIVE_PLATFORM_NAME =~ "simulator"  				      \
&&   "${WRAPPER_EXTENSION}" == "framework" ]] && GO_SIM_FWK    || \
[[ $EFFECTIVE_PLATFORM_NAME != -iphoneos ]]   && NOTIFY "dunno what to do" 0 || {

     HASH=$(md5 -q "$EXE")
  HASHKEY="$TARGET_NAME${EFFECTIVE_PLATFORM_NAME:--$PLATFORM_NAME}"
SAVEDHASH="$(defaults read com.mrgray.AtoZ $HASHKEY)" 2> /dev/null # check saved hash

[[ "$HASH" == "$SAVEDHASH" ]] && say "$TARGET_NAME hashes match!" && exit 0

ssh -q 6 -C "[[ -d /Library/Frameworks/$WRAPPER_NAME ]]" && \
  NOTIFY "Skipping $TARGET_NAME Hashes match, files exist, aborting" 0

logger "Installing TARGET_NAME Framework onto device."

scp -r  "$CODESIGNING_FOLDER_PATH" 6:/Library/Frameworks 2>&1 | head -n1 | sed 's/ssh://;s/6\.local.*//g'

[[ $? == 0 ]] && { say "installed ${TARGET_NAME/#AtoZ/} framework on device"; } \
              || say "copy to device failed for ${TARGET_NAME/#AtoZ/}. $RES"

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