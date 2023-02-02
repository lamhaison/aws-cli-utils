#!/bin/bash

aws_assume_role_check_log() {
	local log_file_path=${aws_cli_logs}/${ASSUME_ROLE}.log
	view +$ -c 'set number' ${log_file_path}
}
