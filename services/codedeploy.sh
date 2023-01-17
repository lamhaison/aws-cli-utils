#!/bin/bash

aws_codedeploy_list_deployments() {
	aws_run_commandline 'aws deploy list-deployments'
}

aws_codedeploy_get_deployment() {
	aws_codedeploy_deployment_id=$1
	aws_run_commandline "
		aws deploy get-deployment --deployment-id \
			${aws_codedeploy_deployment_id:?'aws_codedeploy_deployment_id is unset or empty'}
	"
}

aws_codedeploy_get_deployment_with_hint() {
	aws_codedeploy_get_deployment $(echo "$(peco_aws_codedeploy_list_deployment_ids)" | peco)
}
