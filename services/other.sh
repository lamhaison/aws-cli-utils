#!/bin/bash

aws_datapipeline_list() {
	aws datapipeline list-pipelines
}

aws_datapipeline_check_using() {
	aws_account_info
	echo "List all data pipelines"
	aws datapipeline list-pipelines
}

aws_resource_list() {

	aws_run_commandline "\
		aws resourcegroupstaggingapi get-resources
	"
}

#
# TODO aws_resource_list_by_tag_name to list all resource that have tag Name is
# @param	TODO The first parameter is the tag_name value
# @return List resources that match the tag name which you pass to the function.
#
aws_resource_list_by_tag_name() {
	aws_run_commandline "\
		aws resourcegroupstaggingapi get-resources \
			--tag-filters 'Key=Name,Values=${1:?lhs_aws_resource_tag_name is unset or empty}'
	"
}
