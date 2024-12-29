#!/bin/bash

# AWS logs
aws_logs_list() {
	aws_run_commandline 'aws logs describe-log-groups --query "*[].logGroupName"'
}

function aws_logs_tail() {
	aws_log_group_name=$1

	# Check aws_log_group_name invalid
	if [ -z "$aws_log_group_name" ]; then return; fi

	local aws_logs_sinces=${2:-$aws_log_tail_since}
	echo Get log of the group name ${aws_log_group_name:?"aws_log_group_name is unset or empty"}
	local aws_cmd="aws logs tail --follow $aws_log_group_name --since ${aws_logs_sinces}"
	local_lhs_commandline_logging "${aws_cmd}"
	eval ${aws_cmd}
}

function aws_logs_tail_with_hint() {
	echo "Your log group name >"
	aws_log_group_name=$(peco_create_menu 'peco_aws_logs_list')
	aws_logs_tail $aws_log_group_name $1
}

# Function to start an AWS CloudWatch Logs query
aws_logs_run_query() {
	local log_group_names="$1" # Space-separated list of log group names
	local start_time="$2"      # The start time for the query in milliseconds
	local end_time="$3"        # The end time for the query in milliseconds
	local query_string="$4"    # The CloudWatch Logs Insights query string
	local region="$5"          # The AWS region

	# Ensure required parameters are provided
	if [[ -z "$log_group_names" || -z "$start_time" || -z "$end_time" || -z "$query_string" || -z "$region" ]]; then
		echo "Error: Missing required arguments."
		echo "Usage: aws_logs_run_query <log_group_names> <start_time> <end_time> <query_string> <region>"
		return 1
	fi

	# Convert the space-separated list of log groups into a JSON array
	local log_group_json_array
	# from "log-group-1 log-group-2 log-group-3" to ["log-group-1","log-group-2","log-group-3"]
	log_group_json_array=$(printf '%s' "$log_group_names" | awk '{printf "[\"%s\"", $1; for (i=2; i<=NF; i++) printf ",\"%s\"", $i; printf "]"}')

	# Execute the query
	local query_id
	query_id=$(aws logs start-query \
		--log-group-names "$log_group_json_array" \
		--start-time "$start_time" \
		--end-time "$end_time" \
		--query-string "$query_string" \
		--region "$region" \
		--query "queryId" \
		--output text 2>&1)

	# Check for errors
	if [[ $? -ne 0 ]]; then
		echo "Error starting the query: $query_id"
		return 1
	fi

	echo "$query_id"
}

# Function to start an AWS CloudWatch Logs query for multiple log groups
aws_logs_run_query_multi_groups() {
	aws_logs_run_query "$@"
}

# Function to get AWS CloudWatch Logs query results
aws_logs_get_query_results() {
	local query_id="$1" # The query ID returned by aws_logs_run_query
	local region="$2"   # The AWS region

	# Ensure required parameters are provided
	if [[ -z "$query_id" || -z "$region" ]]; then
		echo "Error: Missing required arguments."
		echo "Usage: aws_logs_get_query_results <query_id> <region>"
		return 1
	fi

	# Wait for the query to complete
	local query_status="Running"
	while [[ "$query_status" == "Running" || "$query_status" == "Scheduled" ]]; do
		echo "Waiting for query results..."
		sleep 2
		query_status=$(aws logs get-query-results \
			--query-id "$query_id" \
			--region "$region" \
			--query "status" \
			--output text 2>&1)
	done

	# Check if the query was successful
	if [[ "$query_status" != "Complete" ]]; then
		echo "Error: Query did not complete successfully. Status: $query_status"
		return 1
	fi

	# Retrieve and display query results
	local results
	results=$(aws logs get-query-results \
		--query-id "$query_id" \
		--region "$region" \
		--output json 2>&1)

	if [[ $? -ne 0 ]]; then
		echo "Error retrieving query results: $results"
		return 1
	fi

	echo "$results"
}
