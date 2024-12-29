#!/bin/bash

# TODO LATER
aws_iam_add_policy_to_role() {
	echo "TODO Later"
}

aws_iam_list_users() {
	aws_run_commandline 'aws iam list-users --output table'
}

aws_iam_list_users_info() {

	aws_run_commandline 'aws iam list-users --output table'

	for user_name in $(aws iam list-users --query '*[].{UserName:UserName}' --output text); do
		aws_run_commandline "\
			aws iam get-user --user-name ${user_name}
			aws iam list-attached-user-policies --user-name ${user_name}
		"
	done

}

aws_iam_list_roles_info() {

	aws_run_commandline 'aws iam list-roles --output table'

	for role_name in $(aws iam list-roles --query '*[].{RoleName:RoleName}' --output text); do
		aws_run_commandline "\
			aws iam get-role --role-name ${role_name}
			aws iam list-attached-role-policies --role-name ${role_name}
		"
	done

}

aws_iam_create_instance_profile() {
	aws_iam_ec2_instance_profile_role_name=$1

	local aws_iam_assume_role_policy_document=$(
		cat <<-_EOF_
			{
				"Version": "2012-10-17",
				"Statement": [
				{
					"Sid": "",
					"Effect": "Allow",
					"Principal": {
					"Service": "ec2.amazonaws.com"
					},
					"Action": "sts:AssumeRole"
				}
				]
			}
		_EOF_
	)

	# Create iam role
	aws iam create-role \
		--role-name ${aws_iam_ec2_instance_profile_role_name} \
		--assume-role-policy-document ${aws_iam_assume_role_policy_document}

	# Create iam instance profile
	aws iam create-instance-profile \
		--instance-profile-name ${aws_iam_ec2_instance_profile_role_name}

	aws iam add-role-to-instance-profile \
		--role-name ${aws_iam_ec2_instance_profile_role_name} \
		--instance-profile-name ${aws_iam_ec2_instance_profile_role_name}

}

aws_iam_attach_ssm_policy() {
	aws_iam_policy_ssm_arn="arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
	aws_iam_ec2_instance_profile_role_name=$1

	aws iam attach-role-policy \
		--policy-arn ${aws_iam_policy_ssm_arn} \
		--role-name ${aws_iam_ec2_instance_profile_role_name}

}

aws_iam_create_instance_profile_for_ssh_with_hint() {
	aws_iam_ec2_instance_profile_role_name=$(aws_name_convention_get_iam_instance_profile)
	echo "To create iam ec2 instance profile \
		${aws_iam_ec2_instance_profile_role_name:?'aws_iam_ec2_instance_profile_role_name is unset or empty'}"
	aws_iam_create_instance_profile ${aws_iam_ec2_instance_profile_role_name}
	aws_iam_attach_ssm_policy ${aws_iam_ec2_instance_profile_role_name}
}

aws_iam_list_roles() {
	aws_run_commandline "\
		aws iam list-roles --query '*[].{RoleName:RoleName}'
	"
}

aws_iam_get_role() {
	aws_iam_role_name=$1
	aws_run_commandline "\
		aws iam get-role --role-name \
			${aws_iam_role_name:?'aws_iam_role_name is unset or empty'}
	"
}

aws_iam_get_role_with_hint() {
	aws_iam_get_role $(peco_create_menu 'peco_aws_iam_list_roles')
}

aws_iam_list_role_policies() {
	local aws_iam_role_name=$1
	# aws_iam_get_role ${aws_iam_role_name}

	# Check input invalid
	if [[ -z "$aws_iam_role_name" ]]; then
		echo "AWs IAM RoleName is invalid"
		return
	fi

	aws_run_commandline "\
		aws iam list-attached-role-policies --role-name ${aws_iam_role_name}
	"

	aws_run_commandline "\
		aws iam list-role-policies --role-name ${aws_iam_role_name}
	"

	for policy_name in $(aws iam list-role-policies --role-name ${aws_iam_role_name} --query '*[]' --output text); do
		aws_run_commandline "\
			aws iam get-role-policy \
				--role-name ${aws_iam_role_name} \
				--policy-name $policy_name
		"
	done
}

aws_iam_list_role_policies_with_hint() {
	aws_iam_list_role_policies $(peco_create_menu 'peco_aws_iam_list_roles')
}

aws_iam_get_policy() {
	aws_iam_policy_arn=$1
	aws_run_commandline "\
		 aws iam get-policy --policy-arn \
		 	${aws_iam_policy_arn:?'aws_iam_policy_arn is unset or empty'}

		 aws iam get-policy-version --policy-arn \
		 	${aws_iam_policy_arn:?'aws_iam_policy_arn is unset or empty'} \
		 	--version-id v1
	"
}

aws_iam_get_policy_with_hint() {
	aws_iam_get_policy $(peco_create_menu 'peco_aws_iam_list_attached_policies')
}

aws_iam_list_ec2_instance_profiles() {
	aws_run_commandline "
		 aws iam list-instance-profiles  \
		 	--query '*[].{InstanceProfileName:InstanceProfileName,Arn:Arn}'

	"
}

# For remove iam user
function aws_iam_rm_user_instruction() {

	IAM_USERNAME=$1

	# Check input invalid
	if [[ -z "$IAM_USERNAME" ]]; then return; fi

	# Function to detach managed policies
	aws_iam_user_detach_managed_policies() {
		policies=$(aws iam list-attached-user-policies --user-name "$IAM_USERNAME" --query 'AttachedPolicies[].PolicyArn' --output text)
		for policy in $policies; do
			echo aws iam detach-user-policy --user-name "$IAM_USERNAME" --policy-arn "$policy"
		done
	}

	# Function to remove from IAM groups
	aws_iam_user_remove_from_groups() {
		groups=$(aws iam list-groups-for-user --user-name "$IAM_USERNAME" --query 'Groups[].GroupName' --output text)
		for group in $groups; do
			echo aws iam remove-user-from-group --user-name "$IAM_USERNAME" --group-name "$group"
		done
	}

	# Function to delete inline policies
	aws_iam_user_delete_inline_policies() {
		policies=$(aws iam list-user-policies --user-name "$IAM_USERNAME" --query 'PolicyNames' --output text)
		for policy in $policies; do
			echo aws iam delete-user-policy --user-name "$IAM_USERNAME" --policy-name "$policy"
		done
	}

	# Function to delete access keys
	aws_iam_user_delete_access_keys() {
		access_keys=$(aws iam list-access-keys --user-name "$IAM_USERNAME" --query 'AccessKeyMetadata[].AccessKeyId' --output text)
		for key_id in $access_keys; do
			echo aws iam delete-access-key --user-name "$IAM_USERNAME" --access-key-id "$key_id"
		done
	}

	aws_iam_rm_iam_user() {
		echo aws iam delete-user --user-name "$IAM_USERNAME"
	}

	# Main execution
	aws_iam_user_detach_managed_policies
	aws_iam_user_remove_from_groups
	aws_iam_user_delete_inline_policies
	aws_iam_user_delete_access_keys
	aws_iam_rm_iam_user
}

# IAM Group
function aws_iam_list_groups() {
	aws_run_commandline "aws iam list-groups"
}

function aws_iam_rm_group_instruction() {
	YourGroupName=$1
	echo aws iam delete-group --group-name ${YourGroupName}
}
