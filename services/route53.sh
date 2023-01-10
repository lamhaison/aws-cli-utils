#!/bin/bash
# AWS Route53
aws_route53_list() {
	# aws_run_commandline 'aws route53 list-hosted-zones --query "*[].Name"'
	aws_run_commandline 'aws route53 list-hosted-zones --query \
	"*[].{Id:Id,Name:Name,PrivateZone:Config.PrivateZone}" --output table'
}

aws_route53_get_host_zone() {
	aws_route53_host_zone_id=$1

	aws_run_commandline "aws route53 list-resource-record-sets \
		--hosted-zone-id ${aws_route53_host_zone_id:?'aws_route53_host_zone_id is unset or empty'}"
}
