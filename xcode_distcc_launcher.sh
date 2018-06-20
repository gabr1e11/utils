#!/bin/sh

#
# Author: Francisco Jose Sanchez
# e-mail: francisco.sanchez@socialpoint.es
#
# Configures distcc system variables for usage with the selected Xcode/NDK
# version.
#

XCODE_SUPPORTED_VERSIONS="7.1.1 7.2 7.3.1 8.2.1 8.3.3 9.0"

DEVELOPER_PATHS=""
FOUND_VERSIONS=""
SUPPORTED_DISTCC_HOSTS="fury.socialpoint.es lorna.socialpoint.es fred.socialpoint.es mot.socialpoint.es goody.socialpoint.es"

DEFAULT_DERIVED_DATA_PATH="${HOME}/Library/Developer/Xcode/DerivedData"
CUSTOM_DERIVED_DATA_PATH="/opt/socialpoint/xcode/deriveddata"

#
# It returns whether the supplied Xcode version number is supported by the
# current distcc configuration.
#
# $1 - Xcode version to check if supported.
#
function distcc_xcode_supported() {

  for each_supported_xcode in $XCODE_SUPPORTED_VERSIONS; do
    if [ "$each_supported_xcode" == "$1" ]; then
      return 0
    fi
  done

  return 1
}

#
# Returns in the get_xcode_ver_result var the version number of the specified
# Xcode installation.
#
# $1 - Path to the Xcode installation to get the version number from.
#
get_xcode_ver_result=""
function get_xcode_ver() {
  get_xcode_ver_result=""
  local _RET_CODE=0

  echo "$(export DEVELOPER_DIR=${1}; xcodebuild -version)" | grep "Xcode" | grep -o "[0-9\.].*$" > /dev/null; _RET_CODE=$?
  [ $_RET_CODE = 0 ] || return $_RET_CODE

  get_xcode_ver_result=`echo "$(export DEVELOPER_DIR=${1}; xcodebuild -version)" | grep "Xcode" | grep -o "[0-9\.].*$"`
  return 0
}

#
# Search for Xcode installations under the /Applications directory.
# This function will only search those directories starting with 'Xcode'
# and will fill the variable DEVELOPER_PATHS with a list of supported Xcode
# applications paths.
#
function search_xcode() {
  echo $'\n\n'"[INFO] Searching for Xcode installations..."
  DEVELOPER_PATHS=""

  local _VER=""
  for each_xcode_dir in $(ls /Applications | grep "Xcode"); do
    local XCODE_DIR="/Applications/${each_xcode_dir}"

    get_xcode_ver "${XCODE_DIR}" || continue
    _VER=$get_xcode_ver_result

    if distcc_xcode_supported $_VER ; then
      DEVELOPER_PATHS="${XCODE_DIR} ${DEVELOPER_PATHS}"
      FOUND_VERSIONS="${_VER} ${FOUND_VERSIONS}"
    else
      echo "Found unsupported Xcode version: [$_VER] Path: [${XCODE_DIR}]"
    fi
  done

  if [ "$DEVELOPER_PATHS" == "" ]; then
    echo "[INFO] No Xcode installations found."
  else
    launch_xcode "$DEVELOPER_PATHS" "$FOUND_VERSIONS"
  fi
}

#
# Shows the supplied paths respective Xcode versions to launch.
#
# $1 - Space separated string with each of the paths to the Xcode installations.
#
function launch_xcode() {
  # Print the available Xcode versions.
  local _OPTION_NUMBER=0
  local _MENU_OPTIONS=""
  for each_xcode in $1; do
    _OPTION_NUMBER=$(( $_OPTION_NUMBER + 1 ))
    get_xcode_ver "${each_xcode}" || continue
    _MENU_OPTIONS="${_MENU_OPTIONS}[$_OPTION_NUMBER] Configure DISTCC for this session and launch Xcode ${get_xcode_ver_result}"$'\n'
  done
  _MENU_OPTIONS="${_MENU_OPTIONS}"$'\n'"[0] Back."$'\n'

  while (true); do
    clear
    echo "$_MENU_OPTIONS"
    read -n 1 -p $'\n'"Select option [0-${_OPTION_NUMBER}]: " "opt"

    { echo "$opt" | grep "^[0-9].*$" > /dev/null && (( $opt >= 0 )) && (( $opt <= $_OPTION_NUMBER )); } || { echo $'\n\n'"[ERROR] Invalid option!!!"; sleep 2; continue; }

    # Evaluate validated option.
    if [ $opt = 0 ]; then
      break
    else
      _OPTION_NUMBER=0
      for each_xcode in $1; do
        _OPTION_NUMBER=$(( $_OPTION_NUMBER + 1 ))
        [ $_OPTION_NUMBER = $opt ] || continue
        get_xcode_ver "${each_xcode}" || { echo $'\n'"[ERROR] Fatal error - Couldn't retrieve the Xcode version for the given Xcode installation path: [$each_xcode]"; exit 1; }
        get_host_list_for_xcode "${get_xcode_ver_result}" || { echo $'\n'"[ERROR] Fatal error - Couldn't retrieve the distcc host list for the given Xcode version: [${get_xcode_ver_result}]"; exit 1; }

        # Do now the proper launch
        export DISTCC_HOSTS=$get_host_list_for_xcode_result
        export DEVELOPER_DIR=${each_xcode}/Contents/Developer

        echo $'\n\n'"Launching ${each_xcode}/Contents/MacOS/Xcode"
        echo $'\n\n'"DISTCC hosts configured as follow for this session:"$'\n\t'"${DISTCC_HOSTS}"$'\n\n'
        { "${each_xcode}/Contents/MacOS/Xcode" && echo $'\n'"[INFO] Xcode ${get_xcode_ver_result} exited successfully"$'\n' ; } || echo $'\n'"[ERROR] Exit  code: [$?] - There were errors after using Xcode ${get_xcode_ver_result}"

        sleep 2

      done
    fi

  done
}

#
# Fills the get_distcc_port_for_xcode_result variable with the right port to use
# for configuring distcc for the given xcode version.
#
# $1 - Xcode version
#
get_distcc_port_for_xcode_result=""
function get_distcc_port_for_xcode() {
  get_distcc_port_for_xcode=""

  distcc_xcode_supported "$1" || return 1

  if [ "$1" = "7.1.1" ]; then
    get_distcc_port_for_xcode_result="3621"
  elif [ "$1" = "7.2" ]; then
    get_distcc_port_for_xcode_result="3622"
  elif [ "$1" = "7.3.1" ]; then
    get_distcc_port_for_xcode_result="3623"
  elif [ "${1::1}" = "8" ] || [ "${1::1}" = "9" ]; then
    get_distcc_port_for_xcode_result="3624"
  fi

  return 0
}

#
# Fills the get_host_list_for_xcode_result with the hosts to use for distcc
# for the specified Xcode version.
#
# $1 - Xcode version
#
get_host_list_for_xcode_result=""
function get_host_list_for_xcode() {
  get_host_list_for_xcode_result=""

  distcc_xcode_supported $1 || return 1

  local SLOTS=5

  get_distcc_port_for_xcode "${1}" || { echo $'\n'"[ERROR] Fatal error - Invalid Xcode version: [${1}]"; return 1; }

  for each_host in $SUPPORTED_DISTCC_HOSTS; do
    get_host_list_for_xcode_result="${get_host_list_for_xcode_result} ${each_host}:${get_distcc_port_for_xcode_result}/${SLOTS},lzo,cpp"
  done

  get_host_list_for_xcode_result="$get_host_list_for_xcode_result localhost/`sysctl -n hw.physicalcpu || echo "4"`,lzo,cpp --randomize";

  return 0

}

#
# Configure the system to use distcc targeting the specified version of Xcode.
#
# $1 - Xcode version
#
function configure_distcc_for_xcode() {
  get_host_list_for_xcode "$1" || return 1

  local HOST_FILE="$HOME/.distcc/hosts"
  echo $'\n\n'"Writting to [$HOST_FILE]:"$'\n\n'"$get_host_list_for_xcode_result"$'\n'
  echo "$get_host_list_for_xcode_result" > "$HOST_FILE"
  local RET_VAL=$?

  # Check everything is fine.
  local FILE_CONTENTS="$(cat $HOST_FILE)"
  [ "$FILE_CONTENTS" == "$get_host_list_for_xcode_result" ] || RET_VAL=1

  [ "$RET_VAL" == "0" ] || { echo "[ERROR] There was an error while writting to [$HOST_FILE]"$'\n'"Current file contents"$'\n------- BOF -------\n'"$(cat $HOST_FILE)"$'\n------- EOF -------\n'; return 1; }

  defaults write com.apple.Xcode PBXNumberOfParallelBuildSubtasks 32
  defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks 32

  return 0
}

#
# $1 - Port to configure distcc for. [3621-3624]
#    3621 - Xcode 7.1.1 (and any Android NDK)
#    3622 - Xcode 7.2 (and any Android NDK)
#    3623 - Xcode 7.3.1 (and any Android NDK)
#    3624 - Xcode 8.2.1/8.3.3 (and any Android NDK)
#
function configure_system_for_distcc_port() {
  if (( $1 < 3621 )) || (( $1 > 3624 )); then
    echo "[ERROR] Invalid port number"
    sleep 5
    return 1
  fi

  local SLOTS=5

  for each_host in $SUPPORTED_DISTCC_HOSTS; do
    HOST_LIST="${HOST_LIST} ${each_host}:${1}/${SLOTS},lzo,cpp"
  done
  HOST_LIST="$HOST_LIST localhost/`sysctl -n hw.physicalcpu || echo "4"`,lzo,cpp --randomize"

  defaults write com.apple.Xcode PBXNumberOfParallelBuildSubtasks 32
  defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks 32

  local HOST_FILE="$HOME/.distcc/hosts"
  echo $'\n\n'"Writting to [$HOST_FILE]:"$'\n\n'"$HOST_LIST"$'\n'
  echo "$HOST_LIST" > "$HOST_FILE"
  local RET_VAL=$?

  # Check everything is fine.
  local FILE_CONTENTS="$(cat $HOST_FILE)"
  [ "$FILE_CONTENTS" == "$HOST_LIST" ] || RET_VAL=1

  [ "$RET_VAL" == "0" ] || { echo "[ERROR] There was an error while writting to [$HOST_FILE]"$'\n'"Current file contents"$'\n------- BOF -------\n'"$(cat $HOST_FILE)"$'\n------- EOF -------\n'; sleep 5; return 1; }

  sleep 5

  return 0
}

function main () {
  clear
  echo "[1] Configure system for DISTCC for Xcode 7.1.1 (also valid for any Android NDK)"
  echo "[2] Configure system for DISTCC for Xcode 7.2 (also valid for any Android NDK)"
  echo "[3] Configure system for DISTCC for Xcode 7.3.1 (also valid for any Android NDK)"
  echo "[4] Configure system for DISTCC for Xcode 8.2.1/8.3.3/9.0 (also valid for any Android NDK)"
  echo $'\n'"[5] Search & launch distcc compatible Xcode installations..."

  echo $'\n'"[9] Erase distcc system configuration"
  echo $'\n'"[0] Exit"

  read -n 1 -p $'\n'"Select option [0-4]: " "opt"

  if [ "$opt" = "1" ]; then
    configure_distcc_for_xcode "7.1.1"
    sleep 2
  elif [ "$opt" = "2" ]; then
    configure_distcc_for_xcode "7.2"
    sleep 2
  elif [ "$opt" = "3" ]; then
    configure_distcc_for_xcode "7.3.1"
    sleep 2
  elif [ "$opt" = "4" ]; then
    configure_distcc_for_xcode "8.2.1"
    configure_system_for_distcc_port 3624
    sleep 2
  elif [ "$opt" = "5" ]; then
    search_xcode
  elif [ "$opt" = "9" ]; then
    rm -rf "$HOME/.distcc/hosts"
    [ -f "$HOME/.distcc/hosts" ] || echo "[INFO] Done!!!"
    sleep 2
  elif [ "$opt" = "0" ]; then
    echo $'\n'
    exit 0
  else
    echo $'\n\n'"Invalid option. Please try again..."
    echo ""
    echo "Press PLAY then any key:"
    read -n 1
  fi
  main
}

if [ ! -d "${CUSTOM_DERIVED_DATA_PATH}" ]; then
  mkdir -p ${CUSTOM_DERIVED_DATA_PATH}
fi

if [ -d "${DEFAULT_DERIVED_DATA_PATH}" ]; then
  if [ ! -L "${DEFAULT_DERIVED_DATA_PATH}" ]; then
      mv -n ${DEFAULT_DERIVED_DATA_PATH}/* ${CUSTOM_DERIVED_DATA_PATH}
      rm -rf ${DEFAULT_DERIVED_DATA_PATH}
      ln -s ${CUSTOM_DERIVED_DATA_PATH} ${DEFAULT_DERIVED_DATA_PATH}
  fi
else
  mkdir -p `basename ${DEFAULT_DERIVED_DATA_PATH}`
  ln -s ${CUSTOM_DERIVED_DATA_PATH} ${DEFAULT_DERIVED_DATA_PATH}
fi

mkdir -p $HOME/.distcc
main
