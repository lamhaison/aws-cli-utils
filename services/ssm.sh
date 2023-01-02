#!/bin/bash

# AWS  SSM

aws_ssm_list_parameters() {

        aws_run_commandline \
        '
        aws ssm get-parameters-by-path \
                --path "/" \
                --recursive \
                --query "Parameters[*].Name"
        '
}

aws_ssm_connection_ec2() {
	instance_id=$1
        echo Connect to the ec2 instance ${instance_id:?"instance_id is unset or empty"}
	aws ssm start-session --target $instance_id
}