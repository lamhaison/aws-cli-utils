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

aws_run_commandline_with_retry() {
	local aws_commandline=$1
	local silent_mode=$2
	local retry_counter=0

	# Check credential valid first
	aws_assume_role_is_tmp_credential_valid

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

aws_run_commandline_with_logging() {
	aws_commandline=$1
	aws_commandline_logging=$(echo ${aws_commandline:?'aws_commandline is unset or empty'} | tr -d '\t' | tr -d '\n')
	# aws_commandline_logging=$(echo ${aws_commandline})
	local log_file_path=${aws_cli_logs}/${ASSUME_ROLE}.log
	if [ "$aws_show_commandline" = "true" ]; then
		local output="tee -a ${log_file_path}"
	else
		local output=">> ${log_file_path}"
	fi

	aws_commandline_result=$(aws_run_commandline_with_retry "${aws_commandline}" "${ignored_error_when_retry}")

	echo "-------------------------------------START--$(date '+%Y-%m-%d-%H-%M-%S')------------------------------------------------" >>${log_file_path}
	echo "Running commandline [ ${aws_commandline_logging} ]" | eval $output
	echo $aws_commandline_result | tee -a ${log_file_path}
	echo "-------------------------------------FINISH-$(date '+%Y-%m-%d-%H-%M-%S')------------------------------------------------" >>${log_file_path}
}
