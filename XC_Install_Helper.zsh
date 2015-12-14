#!/usr/bin/env zsh

# env | sort >! /tmp/XC_Install_Helper.${TARGET_NAME}.env.zsh

[[ -e $TRAVIS ]] && exit 0

RSYNC=/usr/local/bin/rsync
# /usr/bin/rsync
ERR=
DEVICE=ip6
DIFF=/usr/bin/diff

NOTIFY				() {
	type -f terminal-notifier  &&  terminal-notifier -title "$TARGET_NAME" -message "$1" || say "$1"
	[[ "$#" == "2" ]] && exit $2
}

[[ ! -x "${EXE=${CODESIGNING_FOLDER_PATH}/${TARGET_NAME}}" ]] && NOTIFY "Hmm, missing executable:$EXE"  $LINENO
otool -L "$EXE"  || NOTIFY "otool verify failed!" $LINENO

MAC_FW 				() {

  [[ -d "${FW_DIR=${USER_LIBRARY_DIR}/Frameworks}/${WRAPPED_NAME=${TARGET_NAME}.framework}" &&
      ! $($DIFF -x 'Modules' -x ".DS_Store" -rq "${BUILT_PRODUCTS_DIR}/$WRAPPED_NAME" "$FW_DIR/$WRAPPER_NAME") ]] && {

  # NOTIFY "skipping install" 0; 
  } || {

    $RSYNC --recursive --times -v --progress  --links "${BUILT_PRODUCTS_DIR}/$WRAPPED_NAME" "$FW_DIR"
  
      NOTIFY "are SYNCed ${WRAPPED_NAME} status $?" $?;
  }
  
  #  /usr/bin/rsync --recursive --times -v --progress --links --stats "$PROD" "$USER_FWS"
}
GO_DEVICE_APP	() {
	
  exit $(/xbin/installapp "$BUILT_PRODUCTS_DIR/$WRAPPER_NAME") && say "installed ${TARGET_NAME/#AtoZ/} on device"    \
  					 																									 || say "${TARGET_NAME/#AtoZ/} install failed" 
}
GO_SIM_FWK		() {
	    
  mkdir -p "${SIM_FWKS=/Users/$(whoami)/Library/Frameworks-Simulator}"
  cp -fr "${CODESIGNING_FOLDER_PATH}" "$SIM_FWKS"
  NOTIFY "installed into Simulator Frameworks" 0
}

if 		[[ ! $EFFECTIVE_PLATFORM_NAME ]];            		then MAC_FW
elif 	[[       $WRAPPER_EXTENSION != 'framework' ]];	then GO_DEVICE_APP
elif 	[[ $EFFECTIVE_PLATFORM_NAME =~  simulator  &&\
							 $WRAPPER_EXTENSION == 'framework' ]];	then GO_SIM_FWK
elif 	[[ $EFFECTIVE_PLATFORM_NAME != '-iphoneos' ]];	then NOTIFY "dunno what to do" 0
else

	ln -sF "$CODESIGNING_FOLDER_PATH" $THEOS/Frameworks
				 # check saved hash
     HASH=$(md5 -q "$EXE")
  HASHKEY="$TARGET_NAME${EFFECTIVE_PLATFORM_NAME:--$PLATFORM_NAME}"
SAVEDHASH="$(defaults read com.mrgray.AtoZ $HASHKEY)" &> /dev/null

[[ "$HASH" == "$SAVEDHASH" ]] && NOTIFY "$TARGET_NAME hashes match!" 0

ssh -q "$DEVICE" -C "[[ -d /Library/Frameworks/$WRAPPER_NAME ]]" && NOTIFY "Skipping $TARGET_NAME Hashes match, files exist, aborting" 0

NOTIFY "Installing TARGET_NAME Framework onto device."

scp -r  "$CODESIGNING_FOLDER_PATH" "$DEVICE":/Library/Frameworks 2>&1 | head -n1 | sed 's/ssh://;s/6\.local.*//g'

[[ $? != 0 ]] && NOTIFY "copy to device failed for ${TARGET_NAME/#AtoZ/}." $LINENO

NOTIFY "installed ${TARGET_NAME/#AtoZ/} framework on device" 

fi

# EOF

## RPC? -> 1 - GID, ie. 9fc0e1f531df38aed349 -> 2 - Script Name

# [[ -f "${X=/tmp/${SCRIPT_INPUT_FILE_1}}" ]] && rm -f $X
# if curl -s "https://gist.githubusercontent.com/mralexgray/${SCRIPT_INPUT_FILE_0}/raw/${SCRIPT_INPUT_FILE_1}" -o "$X"; then
# chmod +x "$X" && source "$X"
