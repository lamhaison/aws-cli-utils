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
	aws_logs_tail_with_hint_peco
        # echo "List log groups"
        # common_input_to_tmp $(aws logs describe-log-groups --query "*[].logGroupName" --output text)
        # echo "Your log group name >"
        # read aws_log_group_name
	# aws_logs_tail $aws_log_group_name
}

aws_logs_tail_with_hint_peco() {
        echo "List log groups"
        aws_cw_log_group_names=$(aws logs describe-log-groups --query "*[].logGroupName" --output text)
        echo "Your log group name >"
        aws_log_group_name=$(echo ${aws_cw_log_group_names} | tr "\t" "\n" | peco)
        echo You want to get log of ${aws_log_group_name:?"Your aws_log_group_name is unset or empty"}
	aws_logs_tail $aws_log_group_name
}




