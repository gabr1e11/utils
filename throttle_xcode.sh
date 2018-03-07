#!/bin/bash

# Add to this array all the apps you want to throttle down
declare -a PROCESS_NAME_LIST=("com.apple.dt.SKAgent")

# Defaults
ROOT_PROCESS_PID=
CPU_THROTTLE_PERCENT=50
PREV_PROCESS_PID=

function main()
{
    trap_ctrl_c

    ROOT_PROCESS_PID=$(get_current_process_pid)

    if [ "`is_sudo_active`" == "0" ]
    then
        echo "Please, rerun this script with sudo"
        exit 1
    fi

    parse_input_params $@

    for PROCESS_NAME in "${PROCESS_NAME_LIST[@]}"
    do
        ( throttle_process $PROCESS_NAME $CPU_THROTTLE_PERCENT ) &
    done

    # Wait for the subprocesses to finish
    wait

    echo "Done!"
}

# Helper functions
function trap_ctrl_c()
{
    # Kills all processes in the process group
    trap "kill 0" SIGINT
}

function ctrl_c_handler() {
    echo "** Trapped CTRL-C"

    CHILD_PROCESSES_PIDS=$(ps -o pid,ppid -ax | awk "{ if ( \$2 == $ROOT_PROCESS_PID) { print \$1 }}")

    for CHILD_PID in $CHILD_PROCESSES_PIDS
    do
        kill -9 $CHILD_PID 2>/dev/null
    done
}

function is_sudo_active()
{
    if [ "`whoami`" == "root" ]
    then
        echo 1
    else
        echo 0
    fi
}

function parse_input_params()
{
    while getopts ":c:" OPTION
    do
        case $OPTION in
            c)
                CPU_THROTTLE_PERCENT=$OPTARG
                ;;
            *)
                usage $0
                exit 1
                ;;
        esac
    done
}

function usage()
{
    TOOL_NAME=`basename $0`
    echo "$TOOL_NAME [-c]"
    echo "    -c: Sets the maximum CPU percentage to be allowed for the SKAgent"
    echo ""
}

function get_current_process_pid()
{
    echo $$
}

function get_process_pids()
{
    PROCESS_NAME=$1
    PIDS=`ps -ef | grep "$PROCESS_NAME" | grep -v grep | tr -s " " | cut -d' ' -f3`
    echo "$PIDS"
}

function throttle_process()
{
    PROCESS_NAME=$1
    CPU_THROTTLE_PERCENT=$2

    PROCESS_PID=
    PREV_PROCESS_PID=

    while :
    do
        PROCESS_PIDS=$(get_process_pids $PROCESS_NAME)

        # Wait for the process to start
        while [ -z "$PROCESS_PIDS" ] || [ "$PREV_PROCESS_PIDS" == "$PROCESS_PIDS" ]
        do
            sleep 5
            PROCESS_PIDS=$(get_process_pids $PROCESS_NAME)
        done

        # Throttle it down
        for PID in $PROCESS_PIDS
        do
            echo "[$PROCESS_NAME] -> cputhrottle $PID $CPU_THROTTLE_PERCENT"
            cputhrottle $PID $CPU_THROTTLE_PERCENT &
        done

        PREV_PROCESS_PIDS=$PROCESS_PIDS
    done

    echo "DONE"
}

# Call main
main $@
