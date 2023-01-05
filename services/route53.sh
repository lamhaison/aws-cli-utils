#!/bin/bash
# AWS Route53
aws_route53_list() {
	aws_run_commandline 'aws route53 list-hosted-zones --query "*[].Name"'
}
