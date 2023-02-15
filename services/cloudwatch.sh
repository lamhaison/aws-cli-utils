#!/bin/bash

aws_cloudwatch_list_alarms() {
	aws_run_commandline "\
		aws cloudwatch describe-alarms
	"
}

aws_cloudwatch_list_alb_arn() {
	aws_run_commandline "\
		aws elbv2 describe-load-balancers --query '*[].LoadBalancerArn'
	"
}
