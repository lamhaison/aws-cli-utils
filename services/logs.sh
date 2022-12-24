#!/bin/bash

# AWS logs
aws_logs_list() {
	aws logs describe-log-groups --query "*[].logGroupName"
}

aws_logs_tail() {
	aws_log_group_name=$1
	aws logs tail $aws_log_group_name  --since 60m
}

aws_logs_tail_with_hint() {
        echo "List log groups"
        aws_logs_list
        echo "Your log group name >"
        read aws_log_group_name
	aws_logs_tail $aws_log_group_name
}



# AWS cloudformation
aws_cloudformation_list_stack_sets() {
	aws cloudformation list-stack-sets
}