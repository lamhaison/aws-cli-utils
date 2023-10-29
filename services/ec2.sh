#!/bin/bash

# TODO local_aws_ec2_instance_id_peco_menu create ec2 instance_id list
# @param filter by state (running, stopped, all)
# @return ec2_instance_id that you choose
#
local_aws_ec2_instance_id_peco_menu() {
	local instance_state=${1:-'running'}

	if [ "${instance_state}" = "all" ]; then
		local aws_ec2_instance_id=$(peco_create_menu 'peco_aws_ec2_list_all')
	else
		local aws_ec2_instance_id=$(peco_create_menu "peco_aws_ec2_list ${instance_state}")
	fi

	aws_ec2_instance_id=$(echo "${aws_ec2_instance_id}" | awk -F "_" '{print $1}')
	echo ${aws_ec2_instance_id}
}

# AWS ec2
# List all ec2 instance(don't care stopped or running instances)
aws_ec2_list_all() {
	aws_run_commandline \
		"aws ec2 describe-instances \
		--query 'Reservations[].Instances[].{Name: Tags[?Key==\`Name\`].Value | [0], \
			InstanceId:InstanceId,ImageId:ImageId,InstanceType:InstanceType,PrivateIp:PrivateIpAddress,\
			PublicIp:PublicIpAddress,State:State.Name,LaunchTime:LaunchTime,ZInstanceLifecycle:InstanceLifecycle}' \
		--output table
	"
}

aws_ec2_list_all_sort_by_launching_time() {
	aws ec2 describe-instances \
		--filter Name=instance-state-name,Values=running \
		--query 'Reservations[*].Instances[*].[LaunchTime,State.Name,ImageId,InstanceId,PrivateIpAddress,PublicIpAdress,InstanceLifecycle,Tags[?Key==`Name`] | [0].Value][] | sort_by(@, &[0])' \
		--output table

}

# Only list all the running instances.
aws_ec2_list() {
	aws_run_commandline \
		"aws ec2 describe-instances \
		--filters Name=instance-state-name,Values=running \
		--query 'Reservations[].Instances[].{Name: Tags[?Key==\`Name\`].Value | [0], \
			InstanceId:InstanceId,ImageId:ImageId,InstanceType:InstanceType,PrivateIp:PrivateIpAddress,\
			PublicIp:PublicIpAddress,State:State.Name,LaunchTime:LaunchTime,ZInstanceLifecycle:InstanceLifecycle}' \
		--output table
	"
}

aws_ec2_get() {
	aws_run_commandline "\
		aws ec2 describe-instances \
			--instance-ids ${1:?"The aws_ec2_instance_id is unset or empty"}
	"
}

aws_ec2_get_with_hint() {
	aws_ec2_get $(local_aws_ec2_instance_id_peco_menu)
}

aws_ec2_reboot() {
	aws_run_commandline "\
		aws ec2 reboot-instances \
			--instance-ids ${1:?"The aws_ec2_instance_id is unset or empty"}
	"
}

aws_ec2_stop() {
	aws_run_commandline "\
		aws ec2 stop-instances \
			--instance-ids ${1:?"The aws_ec2_instance_id is unset or empty"}
	"
}

aws_ec2_stop_with_hint() {
	aws_ec2_stop $(local_aws_ec2_instance_id_peco_menu)
}

aws_ec2_start() {
	aws_run_commandline "\
		aws ec2 start-instances \
			--instance-ids ${1:?"The aws_ec2_instance_id is unset or empty"}
	"
}

aws_ec2_start_with_hint() {
	aws_ec2_start $(local_aws_ec2_instance_id_peco_menu 'stopped')
}

aws_ec2_rm_instruction() {
	aws_commandline_logging "\
		aws ec2 terminate-instances \
			--instance-ids ${1:-"\$aws_ec2_instance_ids"}
	"
}

aws_ec2_rm_instruction_with_hint() {
	aws_commandline_logging "\
		aws ec2 terminate-instances \
			--instance-ids $(local_aws_ec2_instance_id_peco_menu)
	"
}

# Ec2 image
aws_ec2_list_images() {
	aws_run_commandline "aws ec2 describe-images --owners self"
}

aws_ec2_list_aws_default_images() {
	aws_run_commandline " \
		aws ec2 describe-images \
			--filters 'Name=architecture,Values=x86_64' \
			'Name=virtualization-type,Values=hvm' 'Name=root-device-type,Values=ebs' \
			'Name=block-device-mapping.volume-type,Values=gp2' \
			'Name=ena-support,Values=true' 'Name=owner-alias,Values=amazon' \
			'Name=name,Values=*amzn2-ami-hvm-2.0.????????.?-x86_64-gp2' \
			--query 'Images[*].[ImageId,Name,Description]' --output table
	"
}
aws_ec2_create_image() {
	local aws_ec2_instance_id=$1
	echo To create a image from the ec2 instance ${aws_ec2_instance_id:?"The instace_id is unset or empty"}
	aws_ec2_instance_name=$(aws ec2 describe-instances \
		--instance-ids $aws_ec2_instance_id \
		--query 'Reservations[*].Instances[*].{Tags:Tags[?Key == `Name`] | [0].Value}' \
		--output text)

	aws ec2 create-image \
		--no-reboot \
		--instance-id $aws_ec2_instance_id \
		--name ${aws_ec2_instance_name}-$(date '+%Y-%m-%d-%H-%M-%S') \
		--description ${aws_ec2_instance_name}-$(date '+%Y-%m-%d-%H-%M-%S') \
		--query "ImageId" --output text
}

aws_ec2_create_image_with_hint() {
	aws_ec2_create_image $(local_aws_ec2_instance_id_peco_menu)
}

aws_ec2_get_image() {
	image_id=$1
	echo Get detail of the image ${image_id:?"The image_id is unset or empty"}
	aws_run_commandline "aws ec2 describe-images --image-ids $image_id"
}

aws_ec2_connect() {
	aws_ssm_connection_ec2 $1
}

aws_ec2_connect_with_hint() {
	aws_ssm_connection_ec2 $(local_aws_ec2_instance_id_peco_menu)
}

aws_ec2_list_eips() {
	aws_run_commandline 'aws ec2 describe-addresses'
}

# VPC
aws_ec2_list_vpcs() {
	aws_run_commandline "\
		aws ec2 describe-vpcs \
			--query '*[].{Id:VpcId,CidrBlock:CidrBlock,Name:Tags[?Key == \`Name\`] | [0].Value}' --output table
	"
}

aws_vpc_list() {
	aws_ec2_list_vpcs
}

aws_vpc_check_private_dns_supported() {
	local vpc_id=$1

	# Check input invalid
	if [ -z "$vpc_id" ]; then return; fi

	aws ec2 describe-vpc-attribute --vpc-id ${vpc_id} --attribute enableDnsSupport
	aws ec2 describe-vpc-attribute --vpc-id ${vpc_id} --attribute enableDnsHostnames

}

# Subnets
aws_subnet_list() {

	aws_ec2_list_subnets
}

aws_ec2_list_subnets() {
	aws_run_commandline "\
		aws ec2 describe-subnets \
			--query '*[].{AName:Tags[?Key==\`Name\`].Value | [0],SubnetId:SubnetId,VpcId:VpcId,CidrBlock:CidrBlock,AvailableIpAddressCount:AvailableIpAddressCount \
				AvailabilityZone:AvailabilityZone}' --output table
	"
}

# AWS EBS
aws_volumes_list() {
	aws_run_commandline "\
		 aws ec2 describe-volumes --query '*[].{VolumeId:VolumeId,AvailabilityZone:AvailabilityZone,State:State,Name:Tags[?Key==\`Name\`].Value | [0],KubernetesCluster:Tags[?Key==\`KubernetesCluster\`].Value | [0]}' --output table 
	"
}

# Security group
aws_sg_list() {
	aws_run_commandline "\
		aws ec2 describe-security-groups
	"
}

aws_sg_get() {
	aws_sg_id=$1

	aws_run_commandline "\
		aws ec2 describe-security-groups \
    		--group-ids ${aws_sg_id:?'aws_sg_id is unset or empty'}
	"
}

aws_sg_add_rule_instruction() {
	aws_sg_id=$1

	echo "\
		# Allow access the ssh from a specific IP address
		aws ec2 authorize-security-group-ingress \
		--group-id ${aws_sg_id:-"\$aws_sg_id"} \
		--protocol tcp --port 22 \
		--cidr $(dig +short myip.opendns.com @resolver1.opendns.com)/32
	"
}

aws_region_list() {
	aws_run_commandline "\
		aws ec2 describe-regions \
    		--all-regions \
    		--query 'Regions[].{Name:RegionName,Endpoint:Endpoint}' \
    		--output table
	"
}

aws_ec2_other_commandlines() {
	function local_aws_ec2_other_commandlines_menu() {
		cat <<-__EOF__
			aws_ec2_get \$(local_aws_ec2_instance_id_peco_menu 'all') # Get ec2 instance with hint
			aws_ec2_create_image \$(local_aws_ec2_instance_id_peco_menu 'all') # Create ami image from ec2 with hint
			aws_ec2_start \$(local_aws_ec2_instance_id_peco_menu 'stopped') # Start ec2 instance with hint
			aws_ec2_stop \$(local_aws_ec2_instance_id_peco_menu 'running') # Stop ec2 instance with hint
			aws_ec2_reboot \$(local_aws_ec2_instance_id_peco_menu 'running') # Reboot ec2 instance with hint
			aws_ec2_rm_instruction \$(local_aws_ec2_instance_id_peco_menu 'all') # Remove ec2 instance instruction(Don't apply)

		__EOF__
	}

	local aws_cmd=$(lhs_peco_create_menu 'local_aws_ec2_other_commandlines_menu' | awk -F "#" '{print $1}')

	if [[ -n "${aws_cmd}" ]]; then
		aws_commandline_logging "${aws_cmd}"
		eval ${aws_cmd}
	else
		echo "Do nothing"
	fi

}

aws_ec2_get_credential_from_metadata_instruction() {
	local aws_meta_data_address="http://169.254.169.254"
	cat <<-__EOF__
		# Run on ec2
		iam_role_name=\$(curl -s '${aws_meta_data_address}/latest/meta-data/iam/security-credentials/')
		curl -s ${aws_meta_data_address}/latest/meta-data/iam/security-credentials/\${iam_role_name}
	__EOF__

}

aws_ec2_get_instance_type_spect_instruction() {
	open https://instances.vantage.sh
}

aws_ec2_get_sg_inbound_rules_with_hint() {
	local ec2_instance_id=$(local_aws_ec2_instance_id_peco_menu)
	local list_security_group=$(aws ec2 describe-instances --query "Reservations[].Instances[0].SecurityGroups[].GroupId" --instance-id "$ec2_instance_id" | tr '\t' ' ')
	echo -e "\nIf your security group name is too long and break the table layout, consider to use option -c for column layout.\n"
	echo -e "List Security Groups: " $list_security_group "\n"

	while getopts ":c" opt; do
		case ${opt} in
		c)
			{ echo "GroupName CidrIp FromPort ToPort" && aws ec2 describe-security-groups --group-ids $list_security_group | jq -r '.SecurityGroups[] | {GroupName} as $g | .IpPermissions[] | {FromPort} as $f | {ToPort} as $p | if (.IpRanges | length ) > 0 then (.IpRanges[] | {GroupName: $g.GroupName, CidrIp, FromPort: $f.FromPort, ToPort: $p.ToPort}) else(.UserIdGroupPairs[] as $ug | {GroupName: $g.GroupName, CidrIp: $ug.GroupId, FromPort: $f.FromPort, ToPort: $p.ToPort}) end' | jq -r '(. | [.GroupName, .CidrIp, .FromPort, .ToPort]) | @tsv'; } | column -t
			return 0
			;;
		\?)
			echo "Invalid option, print default table layout. Only option -c is allow."
			;;
		esac
	done

	aws ec2 describe-security-groups --group-ids $list_security_group | jq -r '.SecurityGroups[] | {GroupName} as $g | .IpPermissions[] | {FromPort} as $f | {ToPort} as $p | if (.IpRanges | length ) > 0 then (.IpRanges[] | {GroupName: $g.GroupName, CidrIp, FromPort: $f.FromPort, ToPort: $p.ToPort}) else(.UserIdGroupPairs[] as $ug | {GroupName: $g.GroupName, CidrIp: $ug.GroupId, FromPort: $f.FromPort, ToPort: $p.ToPort}) end' | jq -r '(. | [.GroupName, .CidrIp, .FromPort, .ToPort]) | @tsv' | awk 'function printline() { for(i=0;i<88;i++) printf "-"; printf "\n" } BEGIN {printline(); printf("| %-35s | %-20s | %-10s | %-10s |\n", "GroupName", "CidrIp", "FromPort", "ToPort"); printline()} {printf("| %-35s | %-20s | %-10s | %-10s |\n", $1, $2, $3, $4)} END {printline()}'
}

aws_ec2_get_console_logs() {
	aws_run_commandline "\
		aws ec2 get-console-output \
			--instance-id ${1:?'instance_id is unset or empty'} \
			--output text
	"
}

aws_ec2_get_fingerprint() {
	aws_ec2_get_console_logs $1

}

aws_ec2_get_fingerprint_with_hint() {
	aws_ec2_get_fingerprint $(local_aws_ec2_instance_id_peco_menu)

}
