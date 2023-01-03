#!/bin/bash

aws_lambda_list() {
	aws_run_commandline "aws lambda list-functions"
}


aws_lambda_get() {
	aws_lambda_function=$1
	echo Lambda function ${aws_lambda_function:?"aws_lambda_function is not set or empty"}
	aws_run_commandline "aws lambda get-function --function-name ${aws_lambda_function}"
}


aws_lambda_get_with_hint() {
	echo "List lambda functions"
	aws_lambda_function=$(aws lambda list-functions --query "*[].FunctionName" --output text | tr "\t" "\n" | peco)
	aws_run_commandline "aws lambda get-function --function-name ${aws_lambda_function}"
}

