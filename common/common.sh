aws_assume_role_option_set_output_table() {
	export AWS_DEFAULT_OUTPUT="table"
}

aws_assume_role_option_set_output_json() {
	export AWS_DEFAULT_OUTPUT="json"
}

aws_assume_role_option_set_output_yml() {
	export AWS_DEFAULT_OUTPUT="yaml"
}

aws_assume_role_enable_fast_mode() {
	export aws_assume_role_print_account_info=false
}

aws_assume_role_disable_fast_mode() {
	export aws_assume_role_print_account_info=true
}

aws_assume_role_disable_load_current_assume_role_for_new_tab() {
	rm -rf ${aws_cli_current_assume_role_name} >/dev/null
}

aws_assume_role_disable_show_detail_commandline() {
	export aws_show_commandline=false
}

aws_run_commandline_with_retry() {
	local aws_commandline=$1
	local silent_mode=$2
	local retry_counter=0

	# Check credential valid first
	# aws_assume_role_is_tmp_credential_valid

	while [[ "${retry_counter}" -le "${aws_cli_retry_time}" ]]; do

		if [[ "${silent_mode}" = "true" ]]; then
			eval $aws_commandline 2>/dev/null
		else
			eval $aws_commandline
		fi

		if [[ $? -ne 0 ]]; then
			retry_counter=$(($retry_counter + 1))

			# if [[ "${silent_mode}" = "false" ]]; then
			# 	echo "Retry ${retry_counter}"
			# fi

			sleep ${aws_cli_retry_sleep_interval}
		else
			break
		fi
	done

}

aws_run_commandline() {
	aws_run_commandline=$1
	aws_run_commandline="${aws_run_commandline:?'aws_run_commandline is unset or empty'}"
	aws_run_commandline_with_logging "${aws_run_commandline}"
}

function aws_commandline_logging() {
	local aws_commandline_logging=$(echo ${1:?'aws_commandline is unset or empty'} | tr -d '\t' | tr -d '\n' | tr -s ' ')

	if [ "$aws_show_commandline" = "true" ]; then
		echo "Running commandline [ ${aws_commandline_logging} ]"
	fi
}

aws_run_commandline_with_logging() {
	local aws_commandline=$1
	local log_file_path=${aws_cli_logs}/${ASSUME_ROLE}.log

	if [ "$aws_show_log_uploaded" = "true" ]; then

		local log_uploaded_file_path=${aws_cli_logs}/${ASSUME_ROLE}-uploaded.log
		local tee_command="tee -a ${log_file_path} ${log_uploaded_file_path}"

	else
		local tee_command="tee -a ${log_file_path}"
	fi

	# TODO Later (Consider to remove it because we add aws_commandline_logging function with condition)
	if [ "$aws_show_commandline" = "true" ]; then
		local detail_commandline_tee_command="${tee_command}"
	else
		local detail_commandline_tee_command="${tee_command} > /dev/null"
	fi

	echo "------------------------------STARTED--$(date '+%Y-%m-%d-%H-%M-%S')-----------------------------------------" | eval $tee_command >/dev/null
	aws_commandline_logging ${aws_commandline} | eval $detail_commandline_tee_command
	aws_commandline_result=$(aws_run_commandline_with_retry "${aws_commandline}" "${ignored_error_when_retry}")
	echo $aws_commandline_result | eval $tee_command
	echo "------------------------------FINISHED-$(date '+%Y-%m-%d-%H-%M-%S')-----------------------------------------" | eval $tee_command >/dev/null
}
