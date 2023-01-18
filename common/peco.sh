# brew install peco
# PECO

function peco_select_history() {
	local tac
	if which tac >/dev/null; then
		tac="tac"
	else
		tac="tail -r"
	fi
	commandline=$(history -n 1 |
		eval $tac | peco --on-cancel error)

	echo "Running the commandline again [ ${commandline:?'then commandline is unset or empty'} ]"
	eval ${commandline:?'then commandline is unset or empty'}

}

function peco_history() {
	peco_select_history
}

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
	export aws_assume_role_expired_time=0
}

peco_aws_input() {
	local aws_cli_commandline="${1} --output text"
	local result_cached=$2

	local md5_hash=$(echo $aws_cli_commandline | md5)
	local input_folder=${aws_cli_input_tmp}/${ASSUME_ROLE}
	mkdir -p ${input_folder}
	local input_file_path="${input_folder}/${md5_hash}.txt"
	local empty_file=$(find ${input_folder} -name ${md5_hash}.txt -empty)
	local valid_file=$(find ${input_folder} -name ${md5_hash}.txt -mmin +${peco_input_expired_time})

	# The file is existed and not empty and the flag result_cached is not empty
	if [ -z "${valid_file}" ] && [ -f "${input_file_path}" ] && [ -z "${empty_file}" ] && [ -n "${result_cached}" ]; then
		# Ignore the first line.
		grep -Ev "\*\*\*\*\*\*\*\* \[.*\]" $input_file_path
	else
		local aws_result=$(aws_run_commandline_with_retry "$aws_cli_commandline" "false")

		local format_text=$(peco_format_aws_output_text $aws_result)

		if [ -n "${format_text}" ]; then
			echo "******** [ ${aws_cli_commandline} ] ********" >${input_file_path}
			echo ${format_text} | tee -a ${input_file_path}
		else
			echo "Can not get the data"
		fi

	fi
}

peco_create_menu() {
	input_function=$1
	input_value=$(echo "$(eval $input_function)" | peco)
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

peco_aws_ecr_list_repositorie_names() {
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
	peco_aws_input "aws cloudfront list-distributions --query 'DistributionList.Items[*].{Id:Id}'" 'true'
}

# Autoscaling group
peco_aws_autoscaling_list() {
	peco_aws_input 'aws autoscaling describe-auto-scaling-groups --query "*[].AutoScalingGroupName"' 'true'
}
