#!/bin/bash

###################################################################
# # @script			aws_scheduler.sh
# # @author		 	lamhaison
# # @description	aws_scheduler.sh is a script to manage AWS Scheduler resources.
# # @email		 	lamhaison@gmail.com
###################################################################

function aws_scheduler_list() {
    aws_run_commandline "\
        aws scheduler list-schedules \
            --query 'Schedules[*].[Name,GroupName,State,ScheduleExpression]' --output table
    "

}

function aws_scheduler_get() {
    local schedule_name=$1

    if [[ -z "$schedule_name" ]]; then
        echo "Usage: aws_scheduler_get <schedule_name>"
        return 1
    fi

    aws_run_commandline "\
        aws scheduler get-schedule \
            --name \"$schedule_name\" \
    "
}

function aws_scheduler_get_with_hint() {
    local schedule_name=$(peco_create_menu 'peco_aws_scheduler_list' '--prompt "Choose scheduler name >"')
    aws_scheduler_get "$schedule_name"
}

function aws_scheduler_disable_schedule() {
    local schedule_name=$1

    if [[ -z "$schedule_name" ]]; then
        echo "Usage: aws_scheduler_disable_schedule <schedule_name>"
        return 1
    fi

    # Get the current schedule details
    local schedule_detail
    schedule_detail=$(aws scheduler get-schedule --name "$schedule_name" 2>/dev/null)
    if [[ $? -ne 0 || -z "$schedule_detail" ]]; then
        echo "Failed to get schedule details for '$schedule_name'"
        return 1
    fi

    # Extract required fields from the schedule detail
    local schedule_expression
    local flexible_time_window
    local target

    schedule_expression=$(echo "$schedule_detail" | jq -c -r '.ScheduleExpression')
    flexible_time_window=$(echo "$schedule_detail" | jq -c -r '.FlexibleTimeWindow')
    target=$(echo "$schedule_detail" | jq -c -r '.Target')

    if [[ -z "$schedule_expression" || -z "$flexible_time_window" || -z "$target" ]]; then
        echo "Failed to extract required fields from schedule details."
        return 1
    fi

    aws_run_commandline "\
        aws scheduler update-schedule \
            --name \"$schedule_name\" \
            --state DISABLED \
            --flexible-time-window '$flexible_time_window' \
            --schedule-expression '$schedule_expression' \
            --target '$target'
    "
}

function aws_scheduler_disable_schedule_with_hint() {
    local schedule_name=$(peco_create_menu 'peco_aws_scheduler_list' '--prompt "Choose scheduler name >"')
    aws_scheduler_disable_schedule "$schedule_name"
}

function aws_scheduler_enable_schedule() {
    local schedule_name=$1

    if [[ -z "$schedule_name" ]]; then
        echo "Usage: aws_scheduler_enable_schedule <schedule_name>"
        return 1
    fi

    aws_run_commandline "\
        aws scheduler update-schedule \
            --name \"$schedule_name\" \
            --state ENABLED
    "
}
