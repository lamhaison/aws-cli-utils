#!/bin/bash

# AWS logs
aws_logs_list() {
	aws_run_commandline 'aws logs describe-log-groups --query "*[].logGroupName"'
}

aws_logs_tail() {
	aws_log_group_name=$1
	echo Get log of the group name ${aws_log_group_name:?"aws_log_group_name is unset or empty"}
	aws logs tail --follow $aws_log_group_name --since ${aws_log_tail_since}
}

aws_logs_tail_with_hint() {
	echo "Your log group name >"
	aws_log_group_name=$(peco_create_menu 'peco_aws_logs_list')
	aws_logs_tail $aws_log_group_name
}
