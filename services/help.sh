#!/bin/bash
aws_help() {
	local aws_assume_role_main_function="aws_assume_role_set_name_with_hint"
	local function_list=$(
		cat ${AWS_CLI_SOURCE_SCRIPTS}/{services,common}/* |
			grep -e "^aws*\(.+*\)" | tr -d "(){" |
			grep -v ${aws_assume_role_main_function} |
			sort
	)

	local BUFFER=$(
		echo "${aws_assume_role_main_function}\n${function_list}" | peco --query "$LBUFFER"
	)
	CURSOR=$#BUFFER
}

aws_main_function() {
	local aws_assume_role_main_function="aws_assume_role_set_name_with_hint"
	local BUFFER=$(
		echo "${aws_assume_role_main_function}" | peco --query "$LBUFFER" --select-1
	)
	CURSOR=$#BUFFER

}

# aws_run() {
# 	aws_custom_commandline=$(cat ${AWS_CLI_SOURCE_SCRIPTS}/services/* | grep -e "^aws*\(.+*\)" | grep "with_hint" | tr -d "(){" | sort | peco)
# 	echo Running the commandline ${aws_custom_commandline:?"The commandline is unset or empty. Then do nothing"}
# 	eval $aws_custom_commandline
# }
