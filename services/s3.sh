#!/bin/bash

aws_s3_ls() {
	aws_run_commandline "aws s3 ls"

}
aws_s3_list() {
	aws_run_commandline 'aws s3api list-buckets --query "Buckets[].Name"'
}

aws_s3_get_object_metadata() {
	bucket_name=$1
	object_key=$2

	commandline=$(echo aws s3api head-object --bucket ${bucket_name:?"bucket_name is unset or empty"} \
		--key ${object_key:?"object_key is unset or empty"})

	aws_run_commandline "${commandline}"

}

# aws_s3_get_object_metadata_with_hint() {
# 	bucket_name=$(echo "$(peco_aws_s3_list)" | peco)
# 	object_key=$2

# 	commandline=$(echo aws s3api head-object --bucket ${bucket_name:?"bucket_name is unset or empty"} \
# 		--key ${object_key:?"object_key is unset or empty"})

# 	aws_run_commandline "${commandline}"

# }
