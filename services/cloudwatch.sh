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

aws_cloudwatch_list_dashboards() {
	aws_run_commandline "\
		aws cloudwatch list-dashboards \
			--query '*[].{DashboardName:DashboardName,LastModified:LastModified}'
	"
}

# To return json for the dashboard
aws_cloudfront_get_dashboard() {
	aws_run_commandline "\
		aws cloudwatch get-dashboard \
			--dashboard-name ${1:?'aws_cloudwatch_dashboard_name is unset or empty'} \
			--query 'DashboardBody' --output text
	"
}

aws_cloudfront_update_dashboard() {
	echo "Load dashboard data from file ${2}"
	local aws_coudwatch_dashboard_body=$(cat $2)
	aws cloudwatch put-dashboard \
		--dashboard-name ${1:?'aws_cloudwatch_dashboard_name is unset or empty'} \
		--dashboard-body ${aws_coudwatch_dashboard_body}

}
