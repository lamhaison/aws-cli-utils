# AWS Route53
aws_route53_list() {
	aws route53 list-hosted-zones --query "*[].Name"
}


