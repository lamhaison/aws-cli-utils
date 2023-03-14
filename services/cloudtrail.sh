#!/bin/bash
#
# @version 		1.0
# @script		cloudtrail.sh
# @description	TODO : List functions for cloudtrail
#
##

aws_cloudtrail_get_aws_config_set_recorder_event_instruction() {
	cat <<-__EOF__
		fields @timestamp, @message
		| sort @timestamp desc
		| limit 20
		| filter eventSource = 'config.amazonaws.com'
		| stats count() as count by eventName

		fields @timestamp, @message
		| filter eventSource = 'config.amazonaws.com' and eventName = 'StartConfigurationRecorder'

	__EOF__
}

aws_cloudtrail_list_event_names() {
	local_aws_cloudtrail_list_event_name_peco_menu() {
		local aws_cloudtrail_event_name="https://gist.githubusercontent.com/vltlhson/da04f0c3b2a114f952bac215d3808223/raw/255a9435d2b71fdb900739355699b3ddffa414c2/cloudTrailEventNames.list"
		curl --silent -q --request GET ${aws_cloudtrail_event_name}
	}

	local_aws_cloudtrail_list_event_name_peco_menu | peco
}
