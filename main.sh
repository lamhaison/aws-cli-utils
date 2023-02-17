# Get the current directory of the main.sh script.
export AWS_CLI_SOURCE_SCRIPTS="$(dirname -- "$0")"

export assume_role_password_encrypted="$(cat ~/.password_assume_role_encrypted)"
export tmp_credentials="/tmp/aws_temporary_credentials"
export aws_cli_results="${AWS_CLI_SOURCE_SCRIPTS}/aws_cli_results"
export aws_cli_logs="${AWS_CLI_SOURCE_SCRIPTS}/aws_cli_results/logs"
export aws_cli_images="${AWS_CLI_SOURCE_SCRIPTS}/aws_cli_results/images"
export aws_cli_input_tmp="${AWS_CLI_SOURCE_SCRIPTS}/aws_cli_results/inputs"
export aws_tmp_input="/tmp/aws_tmp_input_23647494949484.txt"
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

# Default settings AWSCLI
export AWS_DEFAULT_OUTPUT="json"

# add some help aliases
alias get-account-alias='aws iam list-account-aliases'
alias get-account-id='echo AccountId $(aws sts get-caller-identity --query "Account" --output text)'

# Import sub-commandlines.
for script in $(find ${AWS_CLI_SOURCE_SCRIPTS} -type f -name '*.sh' | grep -v main.sh); do
	source $script
done

# Add hot-keys
# zle -N aws_help
zle -N aws_main_function
bindkey '^@' aws_main_function
# bindkey '^e' aws_help
