#!/bin/bash

aws_lambda_list() {
	aws_run_commandline "aws lambda list-functions"
}
