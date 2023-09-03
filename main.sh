#!/bin/bash
#
# @version 		1.0
# @script		main.sh
# @description	TODO : to load function for aws-cli-utils
# $1: Where is looking for sh files and source the list
# $2: Where do you want to save logs?
# $3: Do you want to set the bind key?

AWS_CLI_SOURCE_SCRIPTS=$1

if [[ -z "${AWS_CLI_SOURCE_SCRIPTS}" ]]; then
	LOCAL_AWS_CLI_SOURCE_SCRIPTS=$(dirname -- "$0")
	if [[ "${LOCAL_AWS_CLI_SOURCE_SCRIPTS}" = "." ]]; then
		DEFAULT_AWS_CLI_SOURCE_SCRIPTS='/opt/lamhaison-tools/aws-cli-utils'
	fi

	export AWS_CLI_SOURCE_SCRIPTS="${LOCAL_AWS_CLI_SOURCE_SCRIPTS:-${DEFAULT_AWS_CLI_SOURCE_SCRIPTS}}"
else
	export AWS_CLI_SOURCE_SCRIPTS=${AWS_CLI_SOURCE_SCRIPTS}
fi

AWS_CLI_DATA=$2
if [[ -z "${AWS_CLI_DATA}" ]]; then
	LOCAL_AWS_CLI_DATA=$(dirname -- "$0")
	if [[ "${LOCAL_AWS_CLI_DATA}" = "." ]]; then
		DEFAULT_AWS_CLI_DATA='/opt/lamhaison-tools/aws-cli-utils'
	fi

	export AWS_CLI_DATA="${LOCAL_AWS_CLI_DATA:-${DEFAULT_AWS_CLI_DATA}}"
else
	export AWS_CLI_DATA=${AWS_CLI_DATA}
fi

export assume_role_password_encrypted="$(cat ~/.password_assume_role_encrypted)"
export tmp_credentials="/tmp/aws_temporary_credentials"

export aws_cli_results="${AWS_CLI_DATA}/aws_cli_results"
export aws_cli_logs="${AWS_CLI_DATA}/aws_cli_results/logs"
export aws_cli_images="${AWS_CLI_DATA}/aws_cli_results/images"
export aws_cli_input_tmp="${AWS_CLI_DATA}/aws_cli_results/inputs"
export aws_cli_input_folder="${AWS_CLI_DATA}/aws_cli_inputs"
export aws_cli_list_commands_folder="${aws_cli_input_folder}/aws_services_commands"
export aws_tmp_input="/tmp/aws_tmp_input_23647494949484.txt"
export aws_cli_document_root_url="https://awscli.amazonaws.com/v2/documentation/api/latest/reference"
export aws_assume_role_print_account_info="false"
export aws_cli_retry_time=10
export aws_cli_retry_sleep_interval=1
export ignored_error_when_retry="false"
# max session 1h
# The result of aws cli will be cached in x minute (10 minutes) for poco searching menu.
export peco_input_expired_time=10
export aws_assume_role_expired_time=60
# To allow log detail of the aws cli [true|false]
export aws_show_commandline=true
# To allow log information to make as evident and upload to the ticket. [true|false]
export aws_show_log_uploaded=false
export aws_log_tail_since=120m

mkdir -p ${tmp_credentials}
mkdir -p ${aws_cli_results}
mkdir -p ${aws_cli_logs}
mkdir -p ${aws_cli_input_tmp}
mkdir -p ${aws_cli_list_commands_folder}

# Default settings AWSCLI
export AWS_DEFAULT_OUTPUT="json"

# add some help aliases
alias get-account-alias='aws iam list-account-aliases --query "*[0]" --output text'
alias get-account-id='echo AccountId $(aws sts get-caller-identity --query "Account" --output text)'

# Import sub-commandlines.
for script in $(
	find ${AWS_CLI_SOURCE_SCRIPTS} -type f -name '*.sh' |
		grep -v -E '.*(main.sh|test.sh|temp.sh|aws-cli-utils.sh)$'
); do
	source $script
done

# Reuse session in the new terminal
export aws_cli_current_assume_role_name="/tmp/aws_cli_current_assume_role_SW7DNb48oQB57"
export aws_cli_load_current_assume_role=true
# If the file is not empty
# TODO Later (To check if the credential is expired, don't autoload credential)
if [ "true" = "${aws_cli_load_current_assume_role}" ] && [ -s "${aws_cli_current_assume_role_name}" ]; then
	aws_assume_role_load_current_assume_role_for_new_tab
fi

LHS_BIND_KEY=${3:-'True'}

if [[ "${LHS_BIND_KEY}" = "True" ]]; then
	# Add hot-keys
	# zle -N aws_help
	zle -N aws_main_function
	bindkey '^@' aws_main_function

	zle -N aws_get_command
	# Hotkey: Option + a + c
	bindkey 'åç' aws_get_command

	bindkey '∫' aws_get_command

	zle -N aws_history
	# Hotkey Option + ah
	bindkey '˙' aws_history
# bindkey '^e' aws_help
fi
