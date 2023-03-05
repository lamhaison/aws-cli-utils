#!/bin/bash

# TODO LATER
aws_iam_add_policy_to_role() {
	echo "TODO Later"
}

aws_iam_list_users() {
	aws_run_commandline 'aws iam list-users --output table'
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
	aws_iam_role_name=$1
	# aws_iam_get_role ${aws_iam_role_name}

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
