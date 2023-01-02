#!/bin/bash

# AWS cloudformation
aws_cloudformation_list_stack_sets() {
	aws_run_commandline "aws cloudformation list-stack-sets"
}
