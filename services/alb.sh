#!/bin/bash

aws_alb_list() {
	aws_run_commandline "aws elbv2 describe-load-balancers"
}

aws_alb_info() {

	for alb_arn in $(aws elbv2 describe-load-balancers --query "*[].LoadBalancerArn" --output text); do
		aws_alb_get_listeners $alb_arn

		for listener_arn in $(peco_aws_alb_list_listners ${alb_arn}); do
			aws_alb_get_rules $listener_arn
		done

	done

}

aws_alb_get_listeners() {
	aws_alb_arn=$1
	aws_run_commandline \ "
		aws elbv2 describe-listeners \
			--load-balancer-arn ${aws_alb_arn:?'aws_alb_arn is unset or empty'}
	"
}

aws_alb_get_listner() {
	echo "TODO Later"
}

aws_alb_get_rules() {
	aws_alb_listner_arn=$1
	aws_run_commandline \ "
		aws elbv2 describe-rules \
    	--listener-arn ${aws_alb_listner_arn:?'aws_alb_listner_arn is unset or empty'}
	"
}
