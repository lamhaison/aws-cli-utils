#!/bin/bash

# TODO LATER
aws_iam_add_policy_to_role() {

}

aws_iam_list_users() {
	aws_run_commandline 'aws iam list-users --output table'
}
