#!/bin/bash

aws_cloudfront_list_detail() {
	aws_run_commandline 'aws cloudfront list-distributions'
}

aws_cloudfront_list() {
	aws_run_commandline \
		"
			aws cloudfront list-distributions \
				--query 'DistributionList.Items[*].{Id:Id,Aliases:Aliases,Comment:Comment,DomainName:DomainName}' \
				--output table
		"

}

aws_cloudfront_get() {
	aws_distribution_id=$1
	echo Get information for cloudfront ${aws_distribution_id:?"Distribution id is uset or empty"}
	aws_run_commandline "aws cloudfront get-distribution --id ${aws_distribution_id}"
}

aws_cloudfront_get_with_hint() {
	aws_distribution_id=$(peco_create_menu 'peco_aws_cloudfront_list' '--prompt "Your Distribution ID >"')
	aws_distribution_id=$(echo ${aws_distribution_id} | awk -F "_" '{print $1}')
	aws_cloudfront_get ${aws_distribution_id}
}

aws_cloudfront_get_alias() {
	aws_run_commandline "\
		aws cloudfront get-distribution \
			--id ${1:?'your_variable_name is unset or empty'} \
			--query '*[].AliasICPRecordals' --output table
	"
}

aws_cloudfront_get_alias_with_hint() {
	aws_distribution_id=$(peco_create_menu 'peco_aws_cloudfront_list' '--prompt "Your Distribution ID >"')
	aws_distribution_id=$(echo ${aws_distribution_id} | awk -F "_" '{print $1}')
	aws_cloudfront_get_alias ${aws_distribution_id}
}

aws_cloudfront_invalidate_cache() {
	aws_distribution_id=$1
	# Start with /
	aws_distribution_path=$2

	echo "Clear cache for the cloudfront \
		${aws_distribution_id:?'aws_distribution_id is unset or empty'} \
		with path ${aws_distribution_path:?'aws_distribution_path is unset or empty'}"

	aws_run_commandline \
		"
		aws cloudfront create-invalidation \
			--distribution-id ${aws_distribution_id} \
			--paths '${aws_distribution_path}'
	"

	echo "\
		How to get the status of the invalidate cloudfront request
		aws cloudfront get-invalidation --id \$aws_cloudfront_invalidation_id --distribution-id $aws_distribution_id
	"

}

aws_cloudfront_invalidate_cache_with_hint() {
	aws_distribution_id=$(peco_create_menu 'peco_aws_cloudfront_list' '--prompt "Your Distribution ID >"')
	aws_distribution_id=$(echo ${aws_distribution_id} | awk -F "_" '{print $1}')
	echo "Your Distribution ID. It will be start with / . For ex /* >"
	read aws_distribution_path
	aws_cloudfront_invalidate_cache $aws_distribution_id $aws_distribution_path
}
