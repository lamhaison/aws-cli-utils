#!/bin/bash

aws_assume_role_get_log() {
	local log_file_path=${aws_cli_logs}/${ASSUME_ROLE}.log
	echo "Read the log ${log_file_path}"
	view +$ -c 'set number' ${log_file_path}
}

aws_assume_role_get_log_uploaded() {
	local log_file_path=${aws_cli_logs}/${ASSUME_ROLE}-uploaded.log
	echo "Read the log ${log_file_path}"
	view +$ -c 'set number' ${log_file_path}
}

# TODO LATER
aws_assume_role_enable_log_uploaded() {
	export aws_show_log_uploaded=true
	local log_uploaded_file_path=${aws_cli_logs}/${ASSUME_ROLE}-uploaded.log
	touch ${log_uploaded_file_path}
	cat /dev/null >${log_uploaded_file_path}
}
