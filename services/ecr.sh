#!/bin/bash

aws_ecr_list_repo() {
	aws_run_commandline "aws ecr describe-repositories --query \"*[].repositoryArn\""
}

aws_ecr_login() {
	aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)
	aws ecr get-login-password --region ${AWS_REGION} | docker login \
		--username AWS --password-stdin ${aws_account_id}.dkr.ecr.${AWS_REGION}.amazonaws.com
}


aws_ecr_list_images() {
	aws_ecr_repo_name=$1
	echo Get images from ecr repo ${aws_ecr_repo_name:?"Repo is not set or empty"}
	aws_run_commandline "aws ecr list-images --repository-name ${aws_ecr_repo_name}"
}

aws_ecr_list_images_with_hint() {
	echo "Your repository name >"
    aws_ecr_list_images $(echo "$(peco_aws_list_repositorie_names)" | peco)
}