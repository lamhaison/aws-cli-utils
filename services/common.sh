aws_run_commandline() {
	aws_commandline=$1
	echo "---------------------------------------------------------START--$(date '+%Y-%m-%d-%H-%M-%S')-----------------------------------------------------------------" >> ${aws_cli_logs}/${ASSUME_ROLE}.log
	echo Running commandline \[ ${aws_commandline:?"Commandline is unset or empty"}\ ] | tee -a ${aws_cli_logs}/${ASSUME_ROLE}.log
	eval $aws_commandline | tee -a ${aws_cli_logs}/${ASSUME_ROLE}.log
	echo "---------------------------------------------------------FINISH-$(date '+%Y-%m-%d-%H-%M-%S')-----------------------------------------------------------------" >> ${aws_cli_logs}/${ASSUME_ROLE}.log
}