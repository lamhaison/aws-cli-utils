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
	aws_lambda_get $(echo "$(peco_aws_lambda_list)" | peco)
}
