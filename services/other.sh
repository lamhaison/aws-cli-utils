#!/bin/bash

aws_datapipeline_list() {
	aws datapipeline list-pipelines
}

aws_datapipeline_check_using() {
	aws_account_infos
	echo "List all data pipelines"
	aws datapipeline list-pipelines
}

aws_autoscaling_lauching_configuration_list() {
	aws autoscaling describe-launch-configurations --query "*[].LaunchConfigurationName"
}
