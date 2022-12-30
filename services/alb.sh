#!/bin/bash

aws_alb_list() {
	aws elbv2 describe-load-balancers
}

aws_alb_info() {

	for alb_arn in $(aws elbv2 describe-load-balancers --query "*[].LoadBalancerArn" --output text); do
		aws elbv2 describe-listeners --load-balancer-arn $alb_arn

	done

}
