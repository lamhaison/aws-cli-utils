peco_assume_role_name() {
	cat ~/.aws/config | grep -e "^\[profile.*\]$" | peco
}

peco_format_name_convention_pre_defined() {
	local peco_input=$1
	echo "${peco_input}" | tr "\t" "\n" | tr -s " " "\n" | tr -s '\n'
}

peco_format_aws_output_text() {
	local peco_input=$1
	echo "${peco_input}" | tr "\t" "\n"
}

peco_aws_acm_list() {
	aws_acm_list | peco
}

peco_name_convention_input() {
	local text_input=$1
	local format_text=$(peco_format_name_convention_pre_defined $text_input)
	echo $format_text
}

peco_create_menu_with_array_input() {
	local text_input=$1
	local format_text=$(peco_format_name_convention_pre_defined $text_input)
	echo $format_text
}

peco_aws_disable_input_cached() {
	export peco_input_expired_time=0
}

peco_aws_input() {
	peco_commandline_input "${1} --output text" $2
}

peco_commandline_input() {

	local commandline="${1}"
	local result_cached=$2
	local input_expired_time="${3:-$peco_input_expired_time}"

	if [ "${peco_aws_disable_input_cached}" = "0" ]; then
		input_expired_time=0
	fi

	local md5_hash=$(echo $commandline | md5)
	local input_folder="${aws_cli_input_tmp}/${ASSUME_ROLE:-NOTSET}"
	mkdir -p ${input_folder}
	local input_file_path="${input_folder}/${md5_hash}.txt"
	local empty_file=$(find ${input_folder} -name ${md5_hash}.txt -empty)
	local valid_file=$(find ${input_folder} -name ${md5_hash}.txt -mmin +${input_expired_time})

	# The file is existed and not empty and the flag result_cached is not empty
	if [ -z "${valid_file}" ] && [ -f "${input_file_path}" ] && [ -z "${empty_file}" ] && [ -n "${result_cached}" ]; then
		# Ignore the first line.
		grep -Ev "\*\*\*\*\*\*\*\* \[.*\]" $input_file_path
	else
		local aws_result=$(aws_run_commandline_with_retry "$commandline" "false")

		local format_text=$(peco_format_aws_output_text $aws_result)

		if [ -n "${format_text}" ]; then
			echo "******** [ ${commandline} ] ********" >${input_file_path}
			echo ${format_text} | tee -a ${input_file_path}
		else
			echo "Can not get the data"
		fi

	fi

}

peco_create_menu() {
	local input_function=$1
	local peco_options=$2
	local peco_command="peco ${peco_options}"
	# local input_value=$(echo "$(eval $input_function)" | eval ${peco_command})
	local input_value=$(eval ${input_function} | eval ${peco_command})
	echo ${input_value:?'Can not get the input from peco menu'}
}

# AWS Logs
peco_aws_logs_list() {
	peco_aws_input 'aws logs describe-log-groups --query "*[].logGroupName"' 'true'
}

# AWS ECS
peco_aws_ecs_list_clusters() {
	peco_aws_input 'aws ecs list-clusters --query "*[]"' 'true'
}

peco_aws_ecs_list_services() {
	peco_aws_input 'aws ecs list-services --cluster $aws_ecs_cluster_arn --query "*[]"'
}

# AWS ECR

peco_aws_ecr_list_repo_names() {
	peco_aws_input 'aws ecr describe-repositories --query "*[].repositoryName"' 'true'
}

peco_aws_ecr_list_images() {
	aws_ecr_repo_name=$1
	peco_aws_input "aws ecr list-images \
		--repository-name ${aws_ecr_repo_name:?'aws_ecr_repo_name is unset or empy'} \
		--query \"imageIds[].{imageTag:imageTag}\""
}

peco_aws_alb_list_listners() {
	aws_alb_arn=$1
	peco_aws_input " \
		aws elbv2 describe-listeners \
			--load-balancer-arn ${aws_alb_arn:?'aws_alb_arn is unset or empty'} \
			--query \"Listeners[*].ListenerArn\""
}

# AWS RDS
peco_aws_list_db_parameter_groups() {
	peco_aws_input 'aws rds describe-db-parameter-groups --query "*[].DBParameterGroupName"' 'true'
}

peco_aws_rds_list_db_cluster_snapshots() {
	peco_aws_input 'aws rds describe-db-cluster-snapshots \
		--snapshot-type manual \
		--query "DBClusterSnapshots[].DBClusterSnapshotIdentifier"'
}

peco_aws_rds_list_db_snapshots() {
	peco_aws_input 'aws rds describe-db-snapshots \
		--snapshot-type manual \
		--query "DBSnapshots[].DBSnapshotIdentifier"'
}

peco_aws_list_db_cluster_parameter_groups() {
	peco_aws_input 'aws rds describe-db-cluster-parameter-groups --query "*[].DBClusterParameterGroupName"' 'true'
}

peco_aws_list_db_clusters() {
	peco_aws_input 'aws rds describe-db-clusters --query "*[].DBClusterIdentifier"' 'true'
}

peco_aws_list_db_instances() {
	peco_aws_input 'aws rds describe-db-instances --query "*[].DBInstanceIdentifier"' 'true'
}

# Lambda
peco_aws_lambda_list() {
	peco_aws_input 'aws lambda list-functions --query "*[].FunctionName"' 'true'
}

# S3
peco_aws_s3_list() {
	peco_aws_input 'aws s3api list-buckets --query "Buckets[].Name"' 'true'
}

# Codebuild
peco_aws_codebuild_list() {
	peco_aws_input 'aws codebuild list-projects --query "*[]"' 'true'
}

peco_aws_codepipeline_list() {
	peco_aws_input 'aws codepipeline list-pipelines --query "*[].name"' 'true'
}

# Codedeploy
peco_aws_codedeploy_list_deployment_ids() {
	peco_aws_input 'aws deploy list-deployments --query "deployments[]"'
}

# Cloudfront
peco_aws_cloudfront_list() {
	commandline="aws cloudfront list-distributions \
		--query 'DistributionList.Items[*].{AId:Id,BComment:Comment}' --output text | tr -s '\t' '_'"
	peco_commandline_input ${commandline} 'true'
}

# Autoscaling group
peco_aws_autoscaling_list() {
	peco_aws_input 'aws autoscaling describe-auto-scaling-groups --query "*[].AutoScalingGroupName"' 'true'
}

# IAM role list
peco_aws_iam_list_roles() {
	peco_aws_input 'aws iam list-roles --query "*[].{RoleName:RoleName}"' 'true'
}

peco_aws_iam_list_attached_policies() {
	peco_aws_input 'aws iam list-policies --scope Local --only-attached --query "*[].Arn"' 'true'
}

# EC2 Instance
peco_aws_ec2_list() {
	local instance_state=${1:-'running'}

	commandline="aws ec2 describe-instances \
		--filters Name=instance-state-name,Values=${instance_state} \
		--query 'Reservations[].Instances[].{Name: Tags[?Key==\`Name\`].Value | [0],InstanceId:InstanceId,PrivateIpAddress:PrivateIpAddress}' \
		--output text | tr -s '\t' '_'"
	peco_commandline_input ${commandline} 'true'
}

peco_aws_ec2_list_all() {
	commandline="aws ec2 describe-instances \
		--query 'Reservations[].Instances[].{Name: Tags[?Key==\`Name\`].Value | [0],InstanceId:InstanceId,PrivateIpAddress:PrivateIpAddress}' \
		--output text | tr -s '\t' '_'"
	peco_commandline_input ${commandline} 'true'
}

peco_aws_ssm_list_parameters() {
	commandline=" \
    aws ssm get-parameters-by-path \
      --path "/" \
      --recursive \
      --query 'Parameters[*].Name' \
      | jq -r '.[]'
  "
	peco_commandline_input ${commandline} 'true'
}

peco_aws_dynamodb_list_tables() {
	peco_aws_input "aws dynamodb list-tables --query 'TableNames[]'" 'true'
}

peco_aws_sqs_list() {
	peco_aws_input 'aws sqs list-queues --query "*[]"' 'true'
}

peco_aws_eks_list_clusters() {
	peco_aws_input 'aws eks list-clusters  --query "*[]"' 'true'
}

peco_aws_cloudformation_list_stacks() {
	peco_aws_input 'aws cloudformation list-stacks --query "*[].StackName"' 'true'
}

peco_aws_imagebuilder_list() {
	peco_aws_input 'aws imagebuilder list-image-pipelines --query "imagePipelineList[*].arn"' 'true'
}

peco_aws_imagebuilder_list_recipes() {
	peco_aws_input 'aws imagebuilder list-image-recipes --query "*[].arn"' 'true'
}

peco_aws_budgets_list() {
	aws_assume_role_get_aws_account_id
	peco_aws_input 'aws budgets describe-budgets --account-id=${AWS_ACCOUNT_ID} --query "*[].BudgetName"' 'true'
}

peco_aws_secretmanager_list() {
	peco_aws_input 'aws secretsmanager list-secrets --query "*[].Name"' 'true'

}

peco_aws_sns_list() {
	peco_aws_input 'aws sns list-topics --query "*[].TopicArn"' 'true'
}
