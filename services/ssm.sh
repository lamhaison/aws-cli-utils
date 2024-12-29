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

aws_ssm_port_forwarding_ec2_for_rds() {
        aws_ec2_instance_id=$1
        aws_rds_endpoint=$2
        local_port=$3
        aws_commandline_logging "\
                aws ssm start-session --target ${aws_ec2_instance_id:?'aws_ec2_instance_id is unset or empty'}
                        --document-name AWS-StartPortForwardingSessionToRemoteHost \
                        --parameters host="${aws_rds_endpoint:?'aws_rds_endpoint is unset or empty'}",portNumber="3306",localPortNumber="${local_port:?'local_port is unset or empty'}"
        "

        if [[ -n "${aws_ec2_instance_id}" || -n "${aws_rds_endpoint}"|| -n "${local_port}" ]]; then
                aws ssm start-session --target $aws_ec2_instance_id \
                        --document-name AWS-StartPortForwardingSessionToRemoteHost \
                        --parameters host="$aws_rds_endpoint",portNumber="3306",localPortNumber="$local_port"
        fi

}
