# brew install peco
# PECO

peco_assume_role_name() {
	cat ~/.aws/config |grep -e "^\[profile.*\]$" | peco
}

peco_format_aws_output_text() {
	peco_input=$1
	echo "${peco_input}" | tr "\t" "\n"
}	

peco_aws_acm_list() {
	aws_acm_list | peco
}

peco_aws_input() {
	aws_cli_commandline=$1
	aws_result=$(eval $aws_cli_commandline)
	format_text=$(peco_format_aws_output_text $aws_result)
	echo ${format_text}
}

# AWS Logs
peco_aws_logs_list() {
	peco_aws_input 'aws logs describe-log-groups --query "*[].logGroupName" --output text'
}

# AWS ECS
peco_aws_ecs_list_clusters() {
	peco_aws_input 'aws ecs list-clusters --query "*[]" --output text'
}

peco_aws_ecs_list_services() {
	peco_aws_input 'aws ecs list-services --cluster $aws_ecs_cluster_arn --query "*[]" --output text'
}
