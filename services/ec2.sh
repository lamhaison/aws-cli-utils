#!/bin/bash

# AWS ec2
# List all ec2 instance(don't care stopped or running instances)
aws_ec2_list_all() {
	aws_run_commandline \
		"aws ec2 describe-instances \
		--query 'Reservations[].Instances[].{Name: Tags[?Key==\`Name\`].Value | [0], \
			InstanceId:InstanceId,InstanceType:InstanceType,PrivateIp:PrivateIpAddress,\
			PublicIp:PublicIpAddress,State:State.Name}' \
		--output table
	"
}

# Only list all the running instances.
aws_ec2_list() {
	aws_run_commandline \
		"aws ec2 describe-instances \
		--filters Name=instance-state-name,Values=running \
		--query 'Reservations[].Instances[].{Name: Tags[?Key==\`Name\`].Value | [0], \
			InstanceId:InstanceId,InstanceType:InstanceType,PrivateIp:PrivateIpAddress,\
			PublicIp:PublicIpAddress,State:State.Name}' \
		--output table
	"
}

aws_ec2_get() {
	instance_id=$1
	echo Get the information of the ec2 ${instance_id:?"The instace_id is unset or empty"}
	aws_run_commandline "aws ec2 describe-instances --instance-ids $instance_id"
}

aws_ec2_reboot() {
	instance_id=$1
	echo Reboot the ec2 instance ${instance_id:?"The instace_id is unset or empty"}
	aws_run_commandline "aws ec2 reboot-instances --instance-ids $instance_id"
}

aws_ec2_stop() {
	instance_id=$1
	echo Stop the ec2 instance ${instance_id:?"The instace_id is unset or empty"}
	aws_run_commandline "aws ec2 stop-instances --instance-ids $instance_id"
}

aws_ec2_start() {
	instance_id=$1
	echo start the ec2 instance ${instance_id:?"The instace_id is unset or empty"}
	aws_run_commandline "aws ec2 start-instances --instance-ids $instance_id"
}

# Ec2 image
aws_ec2_list_images() {
	aws_run_commandline "aws ec2 describe-images --owners self"
}
aws_ec2_create_image() {
	instance_id=$1
	echo To create a image from the ec2 instance ${instance_id:?"The instace_id is unset or empty"}
	aws_ec2_instance_name=$(aws ec2 describe-instances \
		--instance-ids $instance_id \
		--query 'Reservations[*].Instances[*].{Tags:Tags[?Key == `Name`] | [0].Value}' \
		--output text)

	aws ec2 create-image \
		--no-reboot \
		--instance-id $instance_id \
		--name ${aws_ec2_instance_name}-$(date '+%Y-%m-%d-%H-%M-%S') \
		--description ${aws_ec2_instance_name}-$(date '+%Y-%m-%d-%H-%M-%S') \
		--query "ImageId" --output text
}

aws_ec2_get_image() {
	image_id=$1
	echo Get detail of the image ${image_id:?"The image_id is unset or empty"}
	aws_run_commandline "aws ec2 describe-images --image-ids $image_id"
}

aws_ec2_connect() {
	aws_ssm_connection_ec2 $1
}

aws_ec2_list_eips() {
	aws_run_commandline 'aws ec2 describe-addresses'
}

# VPC

aws_ec2_list_vpcs() {
	aws_run_commandline \
		"
		aws ec2 describe-vpcs --query '*[].{Id:VpcId,CidrBlock:CidrBlock,Name:Tags[?Key == \`Name\`] | [0].Value}' --output table
		"
}

aws_vpc_list() {
	aws_ec2_list_vpcs
}

# Subnets
aws_subnet_list() {

	aws_ec2_list_subnets
}

aws_ec2_list_subnets() {
	aws_run_commandline \
		"
		aws ec2 describe-subnets
	"
}
