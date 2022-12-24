

export HISTSIZE=10000
export ssh_user=vltlhson
export assume_role_password_encrypted=`cat ~/.password_assume_role_encrypted`
export tmp_credentials="/tmp/aws_temporary_credentials"
#export AWS_REGION=ap-northeast-1

# add some help aliases
alias l.='ls .* --color=auto'
alias ll='ls -l --color'
alias la='ls -A'
alias get-account-alias='aws iam list-account-aliases'
alias get-account-id='echo AccountId $(aws sts get-caller-identity --query "Account" --output text)'
alias aws-cli-save-commandline-to-history='history -1 >> ~/aws_cli_results/history.json'
alias aws-cli-save-all-commandlines-to-history='history |grep aws | grep -v history >> ~/aws_cli_results/history.json'

alias ssh-add-lamhaison-key='eval `ssh-agent` && ssh-add ~/.ssh/id_rsa_github_lamhaison'


complete -C '/usr/local/bin/aws_completer' aws


import_tmp_credential() {
	eval  $(unzip -p -P $assume_role_password_encrypted ${tmp_credentials}/${ASSUME_ROLE}.zip)
	aws_export_region
}

zip_tmp_credential() {
	cd $tmp_credentials
	echo "Encrypt temporary credential for assume-role ${ASSUME_ROLE} at ${tmp_credentials}/${ASSUME_ROLE}.zip"
	rm -rf $ASSUME_ROLE.zip
	zip -q -P $assume_role_password_encrypted  $ASSUME_ROLE.zip $ASSUME_ROLE && rm -rf $ASSUME_ROLE
	cd -
}

aws_assume_role_unzip_tmp_credential() {
	cd $tmp_credentials
	assume_role_name=$1
	rm -rf ${assume_role_name}
	unzip -P $assume_role_password_encrypted ${assume_role_name}.zip
	echo "You credential is save here ${tmp_credentials}/${assume_role_name}"
	cd -
}

aws_assume_role_remove_tmp_credential() {
	assume_role_name_input=$1
	tmp_credentials_file_zip=${tmp_credentials}/${assume_role_name_input}.zip 
	if [ -f ${tmp_credentials_file_zip} ]; then
		rm -r ${tmp_credentials_file_zip}
	fi
}

aws_export_region() {
	AWS_REGION=$(aws configure get profile.${ASSUME_ROLE}.region)
	export AWS_REGION=$AWS_REGION
}

aws_assume_role_get_credentail() {
	tmp_credentials_file="${tmp_credentials}/${ASSUME_ROLE}"
	echo "Running assume-role ${ASSUME_ROLE}"
	assume-role ${ASSUME_ROLE} > ${tmp_credentials_file}
	empty_file=$(find ${tmp_credentials} -name ${ASSUME_ROLE} -empty)
	if [ -z "${empty_file}" ]; then
		zip_tmp_credential
	else
		echo "Assume role coudn't be succesfull"
	fi

}

aws_call_assume_role() {
	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN
	tmp_credentials_file="${tmp_credentials}/${ASSUME_ROLE}"
	tmp_credentials_file_zip="${tmp_credentials}/${ASSUME_ROLE}.zip"
	
	expired_time=55
	mkdir -p $tmp_credentials
	if [ -f ${tmp_credentials_file_zip} ]; then

		valid_file=$(find ${tmp_credentials} -name ${ASSUME_ROLE}.zip -mmin +${expired_time})
		empty_file=$(find ${tmp_credentials} -name ${ASSUME_ROLE}.zip -empty)
		# Don't find any file is older than expired-time
		if [ -z "${valid_file}" ]  && [ -z "${empty_file}" ]; then
			echo "Re-use the temporary credential of ${ASSUME_ROLE}"
		else
			echo "The credential is older than ${expired_time} or the credential is empty then we will run assume-role ${ASSUME_ROLE} again"
			aws_assume_role_get_credentail ${tmp_credentials_file}
		fi
	else
		aws_assume_role_get_credentail ${tmp_credentials_file}
	fi
	import_tmp_credential
	
}

aws_assume_role_set_name() {
	
	export ASSUME_ROLE=$1
	export assume_role=$1
	
	aws_call_assume_role

	tmp_credentials_file_zip="${tmp_credentials}/${ASSUME_ROLE}.zip"
	if [ -f $tmp_credentials_file_zip ]; then
		mkdir -p ~/aws_cli_results
		cd ~/aws_cli_results
		aws_account_infos
	else
		echo "Please try again, the assume role action was not complete"
	fi	
}

aws_assume_role_set_name_with_hint() {
	
	cat ~/.aws/config |grep profile |grep -v "source"
	echo "Please input your assume role name >"
	read  assume_role_name
	aws_assume_role_set_name $assume_role_name
	echo "You are using the profile ${ASSUME_ROLE}"
}

aws_account_infos() {
	get-account-alias
        get-account-id
}

aws_events_list () {
	for item in $(aws events list-rules --query "*[].Name" --output text); do echo $item; aws events list-targets-by-rule --rule $item; done
}

aws_cloudfront_list() {
	aws cloudfront list-distributions --query "DistributionList.Items[*].{Id:Id,Aliases:Aliases}"
}

aws_datapipeline_list() {
	aws datapipeline list-pipelines
}

aws_lambda_list() {
	aws lambda list-functions
}

aws_events_disable_rule() {

	set -e
	set -x
	rule_name=$1

	aws_account_infos	
	echo "Disable rule ${rule_name}"
	aws events describe-rule --name $1
	aws events disable-rule --name $1
	aws events describe-rule --name $1
	
}


aws_datapipeline_check_using() {
	aws_account_infos
	echo "List all data pipelines"
	aws datapipeline list-pipelines
}


aws_autoscaling_lauching_configuration_list() {
	aws autoscaling describe-launch-configurations --query "*[].LaunchConfigurationName"
}


aws_codepipeline_get_latest_execution_with_hint() {
	
	echo "List pipelines"
	aws codepipeline list-pipelines --query "*[].name"
	
	echo "Your pipeline >"
	read codepipeline_name
	aws_codepipeline_get_latest_execution $codepipeline_name
}

aws_codepipeline_get_latest_execution() {
	
	codepipeline_name=$1
	aws codepipeline list-action-executions --pipeline-name $codepipeline_name --filter pipelineExecutionId=$(aws codepipeline list-pipeline-executions --pipeline-name $codepipeline_name --query "*[0].pipelineExecutionId" --output text) --output table
}


aws_route53_list() {
	aws route53 list-hosted-zones --query "*[].Name"
}


# AWS codebuild


aws_codebuild_list() {
	aws codebuild list-projects
}
aws_codebuild_get_latest_build() {
	aws_codebuild_project_name=$1
	aws codebuild batch-get-builds --ids $(aws codebuild list-builds-for-project --project-name $aws_codebuild_project_name --query "*[] | [1]" | awk -F '"' '{print $2}')
}

aws_codebuild_get_latest_build_with_hint() {
	echo "List codebuilds"
	aws codebuild list-projects
	echo "Your codebuild >"
	read aws_codebuild_project_name
	aws_codebuild_get_latest_build $aws_codebuild_project_name
	
}


aws_codebuild_check_vcs_repos() {
	for project in $(aws codebuild list-projects --query "*[]" --output text)
	do
    		echo "Project ${project}" 
    		aws codebuild batch-get-projects --names ${project} --query "*[].source.{type:type,location:location}"
	done
}



# AWS logs
aws_logs_list() {
	aws logs describe-log-groups --query "*[].logGroupName"
}

aws_logs_tail() {
	aws_log_group_name=$1
	aws logs tail $aws_log_group_name  --since 60m
}

aws_logs_tail_with_hint() {
        echo "List log groups"
        aws_logs_list
        echo "Your log group name >"
        read aws_log_group_name
	aws_logs_tail $aws_log_group_name
}



# AWS cloudformation
aws_cloudformation_list_stack_sets() {
	aws cloudformation list-stack-sets
}


# AWS ec2
aws_ec2_list() {
	aws ec2 describe-instances --query 'Reservations[].Instances[].{Name: Tags[?Key==`Name`].Value | [0], InstanceId:InstanceId,PrivateIp:PrivateIpAddress,PublicIp:PublicIpAddress,State:State.Name}' --output table
}

aws_ec2_get() {
	instance_id=$1
	aws ec2 describe-instances --instance-ids $instance_id
}

aws_ec2_reboot() {
	instance_id=$1
	echo "Reboot the ec2 instance ${instace_id}"
	aws ec2 reboot-instances --instance-ids $instance_id
}


aws_ec2_list_images() {
	aws ec2 describe-images --owners self
}
aws_ec2_create_image() {
	instance_id=$1
	aws_ec2_instance_name=$(aws ec2 describe-instances \
		--instance-ids $instance_id \
		--query 'Reservations[*].Instances[*].{Tags:Tags[?Key == `Name`] | [0].Value}' \
		--output text)

	aws ec2 create-image \
	    --no-reboot \
	    --instance-id $instance_id \
	    --name ${aws_ec2_instance_name}-`date '+%Y-%m-%d-%H-%M-%S'` \
	    --description ${aws_ec2_instance_name}-`date '+%Y-%m-%d-%H-%M-%S'` \
	    --query "ImageId" --output text
}

aws_ec2_get_image() {
	image_id=$1
	aws ec2 describe-images --image-ids $image_id
}
	





# AWS rds


aws_rds_list_db_clusters() {
	aws rds describe-db-clusters  --query "*[].{DBClusterIdentifier:DBClusterIdentifier,DBClusterMembers:DBClusterMembers}"
}

aws_rds_list_db_cluster_parameter_groups() {
	aws rds describe-db-cluster-parameter-groups --query "*[].DBClusterParameterGroupName"
}

aws_rds_list() {
	aws rds describe-db-clusters --query "*[].DBClusterMembers" --output table
}



aws_rds_create_cluster_snapshot() {
        aws_rds_db_cluster_name=$1
        aws rds create-db-cluster-snapshot \
		--db-cluster-identifier  ${aws_rds_db_cluster_name} \
                --db-cluster-snapshot-identifier ${aws_rds_db_cluster_name}-`date '+%Y-%m-%d-%H-%M-%S'`
}


aws_rds_create_instance_snapshot() {
	aws_rds_db_instance_name=$1
	aws rds create-db-snapshot \
    		--db-instance-identifier ${aws_rds_db_instance_name} \
    		--db-snapshot-identifier ${aws_rds_db_instance_name}-`date '+%Y-%m-%d-%H-%M-%S'`
}

aws_rds_audit_log_setting() {
	db_cluster_parameter_group_name=$1
	aws rds describe-db-cluster-parameters \
    		--db-cluster-parameter-group-name ${db_cluster_parameter_group_name} \
    		--query 'Parameters[].{ParameterName:ParameterName,DataType:DataType,ParameterValue:ParameterValue,IsModifiable:IsModifiable} | [?starts_with(ParameterName, `server_audit_log`)] | [?IsModifiable == `true`]'

}

aws_rds_audit_log_disabled () {
	db_cluster_parameter_group_name=$1
	
	aws rds modify-db-cluster-parameter-group \
    		--db-cluster-parameter-group-name $db_cluster_parameter_group_name \
    		--parameters "ParameterName=server_audit_logging,ParameterValue=0,ApplyMethod=immediate" \
                 "ParameterName=server_audit_logs_upload,ParameterValue=0,ApplyMethod=immediate"
}


# AWS acm

aws_acm_list() {
	for item in $(aws acm list-certificates --query "*[].CertificateArn" --output text)
	do 
		aws acm describe-certificate --certificate-arn $item --query "*[].{CertificateArn:CertificateArn,DomainName:DomainName,SubjectAlternativeNames:SubjectAlternativeNames,Type:Type}"
	done
}


# AWS  SSM

aws_ssm_list_parameters() {
        aws ssm get-parameters-by-path \
                --path "/" \
                --recursive \
                --query "Parameters[*].Name"
}

aws_ssm_connection_ec2() {
	instance_id=$1
	aws ssm start-session --target $1
}
