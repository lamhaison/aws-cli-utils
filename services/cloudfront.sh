#!/bin/bash

aws_cloudfront_list() {
	aws cloudfront list-distributions --query "DistributionList.Items[*].{Id:Id,Aliases:Aliases}"
}

aws_cloudfront_get() {
	distribution_id=$1
	echo Get information for cloudfront ${distribution_id:?"Distribution id is uset or empty"}
	aws cloudfront get-distribution --id ${distribution_id}
}

aws_cloudfront_list_with_hint() {
	aws_cloudfront_list
	echo "Your Distribution ID >"
	read distribution_id
	aws_cloudfront_get ${distribution_id}
}