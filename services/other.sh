#!/bin/bash

aws_events_list () {
	for item in $(aws events list-rules --query "*[].Name" --output text); do echo $item; aws events list-targets-by-rule --rule $item; done
}

aws_cloudfront_list() {
	aws cloudfront list-distributions --query "DistributionList.Items[*].{Id:Id,Aliases:Aliases}"
}

aws_datapipeline_list() {
	aws datapipeline list-pipelines
}

aws_lambda_list() {
	aws lambda list-functions
}

aws_events_disable_rule() {

	set -e
	set -x
	rule_name=$1

	aws_account_infos	
	echo "Disable rule ${rule_name}"
	aws events describe-rule --name $1
	aws events disable-rule --name $1
	aws events describe-rule --name $1
	
}


aws_datapipeline_check_using() {
	aws_account_infos
	echo "List all data pipelines"
	aws datapipeline list-pipelines
}


aws_autoscaling_lauching_configuration_list() {
	aws autoscaling describe-launch-configurations --query "*[].LaunchConfigurationName"
}