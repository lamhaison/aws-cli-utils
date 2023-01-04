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
	result_cached=$2

	md5_hash=$(echo $aws_cli_commandline | md5)
	input_folder=${aws_cli_input_tmp}/${ASSUME_ROLE}
	mkdir -p ${input_folder}
	input_file_path="${input_folder}/${md5_hash}.txt"
	empty_file=$(find ${input_folder} -name ${md5_hash}.txt -empty)

	# The file is existed and not empty and the flag result_cached is not empty
	if [ -f "${input_file_path}" ] && [ -z "${empty_file}" ] && [ -n "${result_cached}" ];then
		# Ignore the first line.
		grep -Ev "\*\*\*\*\*\*\*\* \[.*\]" $input_file_path
	else
		aws_result=$(eval $aws_cli_commandline)
		format_text=$(peco_format_aws_output_text $aws_result)
		echo "******** [ ${aws_cli_commandline} ] ********" > ${input_file_path}
		echo ${format_text} | tee -a ${input_file_path}
	fi
}

# AWS Logs
peco_aws_logs_list() {
	peco_aws_input 'aws logs describe-log-groups --query "*[].logGroupName" --output text' 'true'
}

# AWS ECS
peco_aws_ecs_list_clusters() {
	peco_aws_input 'aws ecs list-clusters --query "*[]" --output text' 'true'
}

peco_aws_ecs_list_services() {
	peco_aws_input 'aws ecs list-services --cluster $aws_ecs_cluster_arn --query "*[]" --output text'
}
