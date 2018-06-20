#!/bin/bash

NUM_PARALLEL_TASKS=$1

function usage
{
    echo "xcode_set_tasks [num_tasks]"
    exit 0
}

if [ "x" == "x$NUM_PARALLEL_TASKS" ]
then
    usage
fi

defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks $NUM_PARALLEL_TASKS

CONFIGURED_NUM_TASKS=`defaults read com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks`
echo "XCode parallel compilation tasks set to $CONFIGURED_NUM_TASKS"

