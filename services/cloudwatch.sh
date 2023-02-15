#!/bin/bash

aws_cloudwatch_list_alarms() {
	aws_run_commandline "\
		aws cloudwatch describe-alarms
	"
}

aws_cloudwatch_list_alb_arn() {
	aws_run_commandline "\
		aws elbv2 describe-load-balancers --query '*[].LoadBalancerArn'
	"
}

aws_cloudwatch_get_graph() {
	local aws_cloudwatch_widget_image=$1
	local graph_file_file_name="$(lamhaison_file_name_get_random_name ${ASSUME_ROLE}).png"
	local graph_file_path="${aws_cli_images}/${ASSUME_ROLE}"
	mkdir -p ${graph_file_path}
	aws cloudwatch get-metric-widget-image \
		--metric-widget ${aws_cloudwatch_widget_image} \
		--output-format png --output text | base64 --decode >${graph_file_path}/${graph_file_file_name}

	echo "Access the graph by the url ${graph_file_path}/${graph_file_file_name}"
}
