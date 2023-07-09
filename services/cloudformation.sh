#!/bin/bash

# AWS cloudformation
aws_cloudformation_list_stack_sets() {
	aws_run_commandline "aws cloudformation list-stack-sets"
}

aws_cloudformation_list_stacks() {
	aws_run_commandline "aws cloudformation list-stacks"
}

aws_cloudformation_get_stack_resources() {
	aws_run_commandline "aws cloudformation list-stack-resources --stack-name ${1:?'stack_name is unset or empty'}"
}

aws_cloudformation_get_stack_resources_with_hint() {
	aws_cloudformation_get_stack_resources $(peco_create_menu 'peco_aws_cloudformation_list_stacks' '--prompt "Choose the stack >"')
}

aws_cloudformation_list_stack_resources() {
	for stack_name in $(aws cloudformation list-stacks --query '*[].StackName' --output text); do
		# echo $stack_name
		aws_cloudformation_get_stack_resources ${stack_name}
	done

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
