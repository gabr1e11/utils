#!/bin/bash

# Defaults
CPU_THROTTLE_PERCENT=50
PREV_SKAGENT_PID=

function main()
{
    if [ "`is_sudo_active`" == "0" ]
    then
        echo "Please, rerun this script with sudo"
        exit 1
    fi

    parse_input_params

    while :
    do
        SKAGENT_PID=$(getSKAgentPID)

        # Wait for the process to start
        while [ -z $SKAGENT_PID ] || [ "$PREV_SKAGENT_PID" == "$SKAGENT_PID" ]
        do
            sleep 5
            SKAGENT_PID=$(getSKAgentPID)
        done

        # Throttle it down
        echo "-> cputhrottle $SKAGENT_PID $CPU_THROTTLE_PERCENT"
        cputhrottle $SKAGENT_PID $CPU_THROTTLE_PERCENT &

        PREV_SKAGENT_PID=$SKAGENT_PID
    done
}

# Helper functions
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
    while getopts ":c:" option;
    do
        case $option in
            c)
                CPU_THROTTLE_PERCENT=$OPTARG
                ;;
            *)
                usage
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

function getSKAgentPID()
{
    echo `ps -ef | grep com.apple.dt.SKAgent | grep -v grep | tr -s " " | cut -d' ' -f3`
}

# Call main
main
