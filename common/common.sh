aws_run_commandline() {
	aws_commandline=$1
	log_file_path=${aws_cli_logs}/${ASSUME_ROLE}.log
	if [ "$aws_show_commandline" = "true" ]; then
		output="tee -a ${log_file_path}"
	else
		output=">> ${log_file_path}"
	fi

	echo "-------------------------------------START--$(date '+%Y-%m-%d-%H-%M-%S')------------------------------------------------" >>${log_file_path}
	echo Running commandline \[ ${aws_commandline:?"Commandline is unset or empty"}\ ] | eval $output
	eval $aws_commandline | tee -a ${aws_cli_logs}/${ASSUME_ROLE}.log
	echo "-------------------------------------FINISH-$(date '+%Y-%m-%d-%H-%M-%S')------------------------------------------------" >>${log_file_path}
}
