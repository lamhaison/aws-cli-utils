#!/bin/bash

# AWS  SSM

aws_ssm_list_parameters() {
        aws_run_commandline '\
        aws ssm get-parameters-by-path \
                --path "/" \
                --recursive \
                --query "Parameters[*].Name"
        '
}

aws_ssm_connection_ec2() {
        aws_ec2_instance_id=$1
        echo "Connect to the ec2 instance ${aws_ec2_instance_id:?'aws_ec2_instance_id is unset or empty'} \
                by commandline [ aws ssm start-session --target $aws_ec2_instance_id ]"

        if [[ -n "${aws_ec2_instance_id}" ]]; then
                aws ssm start-session --target $aws_ec2_instance_id
        fi

}
