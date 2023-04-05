#!/bin/bash

# AWS logs
aws_logs_list() {
	aws_run_commandline 'aws logs describe-log-groups --query "*[].logGroupName"'
}

aws_logs_tail() {
	aws_log_group_name=$1
	local aws_logs_sinces=${2:-$aws_log_tail_since}
	echo Get log of the group name ${aws_log_group_name:?"aws_log_group_name is unset or empty"}
	local aws_cmd="aws logs tail --follow $aws_log_group_name --since ${aws_logs_sinces}"
	lhs_commandline_logging "${aws_cmd}"
	eval ${aws_cmd}
}

aws_logs_tail_with_hint() {
	echo "Your log group name >"
	aws_log_group_name=$(peco_create_menu 'peco_aws_logs_list')

	aws_logs_tail $aws_log_group_name $1
}
