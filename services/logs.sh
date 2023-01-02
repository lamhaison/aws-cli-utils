#!/bin/bash

# AWS logs
aws_logs_list() {
	aws_run_commandline 'aws logs describe-log-groups --query "*[].logGroupName"'
}

aws_logs_tail() {
	aws_log_group_name=$1
	echo Get log of the group name ${aws_log_group_name:?"aws_log_group_name is unset or empty"}
	aws logs tail $aws_log_group_name  --since 120m
}

aws_logs_tail_with_hint() {
        echo "List log groups"
        aws_logs_list
        echo "Your log group name >"
        read aws_log_group_name
	aws_logs_tail $aws_log_group_name
}