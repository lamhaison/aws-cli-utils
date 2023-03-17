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

aws_ssm_get_value_parameter_with_hint() {
  parameter_name=$(peco_create_menu 'peco_aws_ssm_list_parameters' '--prompt "Choose Parameter Name >"')
  aws_run_commandline "aws ssm get-parameter --name $parameter_name --with-decryption --query 'Parameter.Value' --output text"
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
