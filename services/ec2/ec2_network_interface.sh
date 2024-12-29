#!/bin/bash

function aws_network_interface_get() {
	local sg_id=$1
	# Check input invalid
	if [ -z "$sg_id" ]; then return; fi
	aws ec2 describe-network-interfaces --filters Name=group-id,Values=${sg_id} --query "NetworkInterfaces[*].[NetworkInterfaceId,Description,PrivateIpAddress,VpcId]" --output table
}
