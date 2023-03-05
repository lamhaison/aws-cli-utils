#!/bin/bash

# AWS  SSM

aws_ssm_list_parameters() {
        aws_run_commandline " \
                aws ssm get-parameters-by-path \
                        --path "/" \
                        --recursive \
                        --query 'Parameters[*].Name'
        "
}

aws_ssm_connection_ec2() {
        aws_ec2_instance_id=$1
        aws_commandline_logging "\
                aws ssm start-session --target ${aws_ec2_instance_id:?'aws_ec2_instance_id is unset or empty'}
        "

        if [[ -n "${aws_ec2_instance_id}" ]]; then
                aws ssm start-session --target $aws_ec2_instance_id
        fi

}
