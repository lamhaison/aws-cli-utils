#!/bin/bash

# AWS  SSM

aws_ssm_list_parameters() {
        aws ssm get-parameters-by-path \
                --path "/" \
                --recursive \
                --query "Parameters[*].Name"
}

aws_ssm_connection_ec2() {
	instance_id=$1
	aws ssm start-session --target $1
}