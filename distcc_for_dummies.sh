#!/bin/sh

#
# $1 - Port to configure distcc for. [3621-3624]
#    3621 - Xcode 7.1.1 (and any Android NDK)
#    3622 - Xcode 7.2 (and any Android NDK)
#    3623 - Xcode 7.3.1 (and any Android NDK)
#    3624 - any Android NDK
#
function write_distcc() {
  if (( $1 < 3621 )) || (( $1 > 3624 )); then
    echo "[ERROR] Invalid port number"
    return 1
  fi
  
  local SLOTS=6
  local HOST_LIST="lorna.socialpoint.es:${1}/${SLOTS},lzo,cpp fred.socialpoint.es:${1}/${SLOTS},lzo,cpp mot.socialpoint.es:${1}/${SLOTS},lzo,cpp goody.socialpoint.es:${1}/${SLOTS},lzo,cpp localhost/4,lzo,cpp"
  if [ "$1" != "3623" ]; then
    SLOTS=5
    HOST_LIST="$HOST_LIST fury.socialpoint.es:${1}/${SLOTS},lzo,cpp"
  fi
  
  defaults write com.apple.Xcode PBXNumberOfParallelBuildSubtasks 32
  defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks 32
  
  local HOST_FILE="$HOME/.distcc/hosts"
  echo $'\n\n'"Writting to [$HOST_FILE]:"$'\n\n'"$HOST_LIST"$'\n'
  echo "$HOST_LIST" > "$HOST_FILE"
  local RET_VAL=$?
  
  # Check everything is fine.
  local FILE_CONTENTS="$(cat $HOST_FILE)"
  [ "$FILE_CONTENTS" == "$HOST_LIST" ] || RET_VAL=1
  
  [ "$RET_VAL" == "0" ] || { echo "[ERROR] There was an error while writting to [$HOST_FILE]"$'\n'"Current file contents"$'\n------- BOF -------\n'"$(cat $HOST_FILE)"$'\n------- EOF -------\n'; return 1; }
  
  return 0
}

function main () {
  clear
  echo "Press 1 to configure DISTCC for Xcode 7.1.1 (also valid for any Android NDK)"
  echo "Press 2 to configure DISTCC for Xcode 7.2 (also valid for any Android NDK)"
  echo "Press 3 to configure DISTCC for Xcode 7.3.1 (also valid for any Android NDK)"
  echo "Press 4 to configure DISTCC for any Android NDK"
  echo "Press 0 to exit without modifications"
  
  read -n 1 -p $'\n'"Select option [0-4]: " "opt"
  
  if [ "$opt" = "1" ]; then
    write_distcc 3621
    exit $?
  elif [ "$opt" = "2" ]; then
    write_distcc 3622
    exit $?
  elif [ "$opt" = "3" ]; then
    write_distcc 3623
    exit $?
  elif [ "$opt" = "4" ]; then
    write_distcc 3624
    exit $?
  elif [ "$opt" = "0" ]; then
    echo $'\n'
    exit 0
  else
    echo $'\n\n'"Invalid option. Please try again..."
    echo "Please try again!"
    echo ""
    echo "Press PLAY then any key:"
    read -n 1
    main
  fi
}

mkdir -p $HOME/.distcc
main
