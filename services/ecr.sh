#!/bin/bash

aws_ecr_list_repo() {
	aws ecr describe-repositories --query "*[].repositoryArn"
}

aws_ecr_login() {
	aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)
	aws ecr get-login-password --region ${AWS_REGION} | docker login \
		--username AWS --password-stdin ${aws_account_id}.dkr.ecr.${AWS_REGION}.amazonaws.com
}