#!/bin/bash

aws_cloudfront_list_detail() {
	aws_run_commandline 'aws cloudfront list-distributions'
}

aws_cloudfront_list() {
	aws_run_commandline \
		"
			aws cloudfront list-distributions \
				--query 'DistributionList.Items[*].{Id:Id,Aliases:Aliases,Comment:Comment}'
		"

}

aws_cloudfront_get() {
	aws_distribution_id=$1
	echo Get information for cloudfront ${aws_distribution_id:?"Distribution id is uset or empty"}
	aws_run_commandline "aws cloudfront get-distribution --id ${aws_distribution_id}"
}

aws_cloudfront_list_with_hint() {
	aws_cloudfront_list
	echo "Your Distribution ID >"
	read aws_distribution_id
	aws_cloudfront_get ${aws_distribution_id}
}

aws_cloudfront_invalidate_cache() {
	aws_distribution_id=$1
	# Start with /
	aws_distribution_path=$2
	aws_run_commandline \
		"
		aws cloudfront create-invalidation \
			--distribution-id ${aws_distribution_id:?'aws_distribution_id is unset or empty'} \
			--paths '${aws_distribution_path}'
	"

}
