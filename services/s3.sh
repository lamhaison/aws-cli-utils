#!/bin/bash

aws_s3_ls() {
	aws_run_commandline "aws s3 ls"

}
aws_s3_list() {
	aws_run_commandline 'aws s3api list-buckets --query "Buckets[].Name"'
}

aws_s3_get_bucket() {
	aws_s3_bucket_name=$1
	aws_run_commandline \
		"
		aws s3 ls s3://${aws_s3_bucket_name:?'aws_s3_bucket_name is unset or empty'}
	"

}

aws_s3_get_bucket_recursived() {
	aws_s3_bucket_name=$1
	aws_run_commandline \
		"
		aws s3 ls s3://${aws_s3_bucket_name:?'aws_s3_bucket_name is unset or empty'} --recursive
	"
}

aws_s3_get_bucket_with_hint() {
	aws_s3_get_bucket $(peco_create_menu 'peco_aws_s3_list')
}

aws_s3_get_bucket_recursived_with_hint() {
	aws_s3_get_bucket_recursived $(peco_create_menu 'peco_aws_s3_list')
}

aws_s3_get_object_metadata() {
	aws_s3_bucket_name=$1
	object_key=$2

	local commandline=$(echo aws s3api head-object --bucket ${aws_s3_bucket_name:?"aws_s3_bucket_name is unset or empty"} \
		--key ${object_key:?"object_key is unset or empty"})

	aws_run_commandline "${commandline}"

}

aws_s3_get_bucket_arn() {
	aws_s3_bucket_name=$1
	echo "arn:aws:s3:::${aws_s3_bucket_name:?'aws_s3_bucket_name is unset or empty'}"
}

aws_s3_get_bucket_arn_with_hint() {
	aws_s3_get_bucket_arn $(peco_create_menu 'peco_aws_s3_list')
}

# aws_s3_get_object_metadata_with_hint() {
# 	bucket_name=$(peco_create_menu 'peco_aws_s3_list')
# 	object_key=$2

# 	commandline=$(echo aws s3api head-object --bucket ${bucket_name:?"bucket_name is unset or empty"} \
# 		--key ${object_key:?"object_key is unset or empty"})

# 	aws_run_commandline "${commandline}"

# }

aws_s3_create() {
	aws_s3_bucket_name=$1
	aws s3api create-bucket \
		--bucket ${aws_s3_bucket_name:?"aws_s3_bucket_name is unset or empty"} \
		--create-bucket-configuration LocationConstraint=${AWS_REGION}
}

aws_s3_rm() {
	aws_s3_bucket_name=$1
	echo "We didn't run the commandline, we just suggest the commandline"
	echo "If you want ot process it please run the commandline \
		[ 
			aws_s3_get_bucket_recursived ${aws_s3_bucket_name:?'aws_s3_bucket_name is unset or empty'}
			aws s3 rm s3://${aws_s3_bucket_name:?'aws_s3_bucket_name is unset or empty'}/ --recursive 
			aws_s3_get_bucket_recursived ${aws_s3_bucket_name:?'aws_s3_bucket_name is unset or empty'}
			aws s3api delete-bucket --bucket ${aws_s3_bucket_name:?'aws_s3_bucket_name is unset or empty'}
			aws_s3_ls
		]
	"
}

aws_s3_rm_with_hint() {
	aws_s3_rm $(peco_create_menu 'peco_aws_s3_list')
}

aws_s3_get_bucket_policy() {
	aws_s3_bucket_name=$1
	aws_run_commandline \
		"
		aws s3api get-bucket-policy \
			--bucket ${aws_s3_bucket_name:?'aws_s3_bucket_name is unset or empty'} \
			--query Policy --output text
	"
}

aws_s3_get_bucket_policy_with_hint() {
	aws_s3_get_bucket_policy $(peco_create_menu 'peco_aws_s3_list')
}
