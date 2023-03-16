#!/bin/bash

# AWS cloudformation
aws_cloudformation_list_stack_sets() {
	aws_run_commandline "aws cloudformation list-stack-sets"
}

aws_cloudformation_get_stack_set() {
	aws_run_commandline "\
		aws cloudformation describe-stack-set \
			--stack-set-name ${1:?'stack_set_name is unset or empty'}

	"
}

aws_cloudformation_stack_info() {

	local lhs_stack_set_names=$(aws cloudformation list-stack-sets --query '*[].StackSetName' --output text)
	for stack_set_name in ${lhs_stack_set_names}; do
		aws_cloudformation_get_stack_set ${stack_set_name}
	done
}
