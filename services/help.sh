#!/bin/bash
aws_help() {
	aws_custom_commandline=$(cat ${AWS_CLI_SOURCE_SCRIPTS}/services/* | grep -e "^aws*\(.+*\)" | tr -d "(){" | sort | peco)
	echo You can run which ${aws_custom_commandline:?"The commandline is unset or empty. Then do nothing"} to get more detail
}

aws_run() {
	aws_custom_commandline=$(cat ${AWS_CLI_SOURCE_SCRIPTS}/services/* | grep -e "^aws*\(.+*\)" | grep "with_hint" | tr -d "(){" | sort | peco)
	echo Running the commandline ${aws_custom_commandline:?"The commandline is unset or empty. Then do nothing"}
	eval $aws_custom_commandline
}
