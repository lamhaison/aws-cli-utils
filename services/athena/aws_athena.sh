#!/bin/bash

###################################################################
# # @script			aws_athena.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
###################################################################

#!/bin/bash

# Function to start an AWS Athena query
aws_athena_run_query() {
	local query_string="$1"   # The SQL query to execute
	local s3_output_path="$2" # The S3 path for query results

	# Validate required parameters
	if [[ -z "$query_string" || -z "$s3_output_path" ]]; then
		echo "Error: Missing required arguments."
		echo "Usage: aws_athena_run_query <query_string> <s3_output_path>"
		return 1
	fi

	# Start the Athena query and get the query execution ID
	local query_execution_id
	query_execution_id=$(aws athena start-query-execution \
		--query-string "$query_string" \
		--result-configuration "OutputLocation=$s3_output_path" \
		--query "QueryExecutionId" \
		--output text 2>&1)

	# Check for errors
	if [[ $? -ne 0 ]]; then
		echo "Error starting the query: $query_execution_id"
		return 1
	fi

	echo "$query_execution_id"
}

# Function to get AWS Athena query results
aws_athena_get_query() {
	local query_execution_id="$1" # The query execution ID
	local region="$2"             # Optional: AWS region (default is set in AWS CLI config)

	# Validate required parameters
	if [[ -z "$query_execution_id" ]]; then
		echo "Error: Missing required argument."
		echo "Usage: aws_athena_get_query <query_execution_id> [region]"
		return 1
	fi

	# Wait for the query to complete
	local query_status="RUNNING"
	while [[ "$query_status" == "RUNNING" || "$query_status" == "QUEUED" ]]; do
		echo "Waiting for query to complete..."
		sleep 2
		query_status=$(aws athena get-query-execution \
			--query-execution-id "$query_execution_id" \
			--query "QueryExecution.Status.State" \
			--output text --region "$region" 2>&1)
	done

	# Check if the query succeeded
	if [[ "$query_status" != "SUCCEEDED" ]]; then
		echo "Error: Query did not succeed. Status: $query_status"
		return 1
	fi

	# Retrieve query results
	local results
	results=$(aws athena get-query-results \
		--query-execution-id "$query_execution_id" \
		--output json --region "$region" 2>&1)

	if [[ $? -ne 0 ]]; then
		echo "Error retrieving query results: $results"
		return 1
	fi

	echo "$results"
}
