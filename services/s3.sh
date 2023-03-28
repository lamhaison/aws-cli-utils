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
	local aws_s3_bucket_name=$1
	# Don't have to specific bucket configuration if it is region us-east-1
	local aws_s3_cmd_created="aws s3api create-bucket --bucket ${aws_s3_bucket_name:?'aws_s3_bucket_name is unset or empty'}"
	if [[ "us-east-1" != "${AWS_REGION}" ]]; then
		aws_s3_cmd_created="${aws_s3_cmd_created} --create-bucket-configuration LocationConstraint=${AWS_REGION}"
	fi

	eval ${aws_s3_cmd_created}

}

aws_s3_rm_instruction() {
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

	# https://stackoverflow.com/questions/29809105/how-do-i-delete-a-versioned-bucket-in-aws-s3-using-the-cli
	# TODO Later (Verify later)
	cat <<-__EOF__

		# Delete all object versioning enabled
		aws s3api put-bucket-lifecycle-configuration \
		  --lifecycle-configuration '{"Rules":[{
		      "ID":"empty-bucket",
		      "Status":"Enabled",
		      "Prefix":"",
		      "Expiration":{"Days":1},
		      "NoncurrentVersionExpiration":{"NoncurrentDays":1}
		    }]}' \
		  --bucket ${aws_s3_bucket_name}

		# Then you just have to wait 1 day and the bucket can be deleted with
		aws s3api delete-bucket --bucket ${aws_s3_bucket_name}

	__EOF__
}

aws_s3_rm_with_hint() {
	aws_s3_rm_instruction $(peco_create_menu 'peco_aws_s3_list')
}

#
# TODO aws_s3_get_location for getting bucket location.
# @param	TODO The first parameter is the bucket name.
# @return Buckets in Region us-east-1 have a LocationConstraint of null .
#
aws_s3_get_location() {
	aws_run_commandline "\
		aws s3api get-bucket-location --bucket ${1}	
	"
}

aws_s3_get_location_with_hint() {
	#
	aws_s3_get_location $(peco_create_menu 'peco_aws_s3_list')
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

#
# TODO to get presign url for s3 object.
# @param	The first parameter is the full path of object including s3 bucket name
# 			For ex: s3://DOC-EXAMPLE-BUCKET/test2.txt
#			The second parameter is the expires-in (integer) Number of seconds until the pre-signed URL expires.
# 			Default is 3600 seconds.
# @return
#

aws_s3_get_presigned_url() {
	aws_run_commandline "\
		aws s3 presign $1 --expires-in ${2:-3600}	
	"

}

aws_s3_cp_folder_instruction() {
	echo "\
		aws s3 cp s3://BUCKET_NAME/cf/cf-domain.com/cf-domain.com-2022-12 \
			s3://NEW_BUCKET_NAME/cf-domain.com-2022-12/00-10 --recursive --exclude \"*\" --include \"CF_ID.2022-12-0*\"
	"

}
