aws_name_convention_get_prefix_name() {
	echo "${ASSUME_ROLE}"
}

aws_name_convention_get_short_env_name() {
	echo "dev stg prd"
}

aws_name_convention_get_long_env_name() {
	echo "development staging production"
}

aws_name_convention_get_with_assume_role_name() {
	local input_name=$1
	echo ${ASSUME_ROLE:="ASSUME_ROLE"}-${input_name:="input_name"}
}

aws_name_convention_get_s3_bucket_name() {
	aws_s3_bucket_name=$1
	echo "The bucket name should will be like that \
		[ ${ASSUME_ROLE:="ASSUME_ROLE"}-${aws_s3_bucket_name:?"aws_s3_bucket_name is unset or empty"}  ]" | tr -s ''
}

aws_name_convention_get_s3_bucket_name_with_hint() {

	aws_name_convention_resource_types="static \
		vod terraform cf-logs \
		alb-logs webapp-react admin-react backup athena-query-results"

	echo "List resource type ${aws_name_convention_resource_types}"

	aws_name_convention_get_s3_bucket_name \
		$(echo "$(peco_name_convention_input $aws_name_convention_resource_types)" | peco)

}

aws_name_convention_get_cloudwatch_dasgboard() {
	aws_name_convention_cloudwatch_dashboard_name="overview \
		benchmark db-connection alb-5xx \
		"

	aws_name_convention_get_with_assume_role_name \
		$(echo "$(peco_name_convention_input $aws_name_convention_cloudwatch_dashboard_name)" | peco)
}

aws_name_convention_get_iam_instance_profile() {
	local aws_name_convention_iam_instance_profile_name="bastion jenkins-master jenkins-slave"
	local name_input=$(echo "$(peco_name_convention_input $aws_name_convention_iam_instance_profile_name)" | peco)
	echo $(aws_name_convention_get_prefix_name)-${name_input:?'name_input is unset or empty'}
}
