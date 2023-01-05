# Get the current directory of the main.sh script.
export AWS_CLI_SOURCE_SCRIPTS="$(dirname -- "$0")"

export assume_role_password_encrypted="$(cat ~/.password_assume_role_encrypted)"
export tmp_credentials="/tmp/aws_temporary_credentials"
export aws_cli_results="${AWS_CLI_SOURCE_SCRIPTS}/aws_cli_results"
export aws_cli_logs="${AWS_CLI_SOURCE_SCRIPTS}/aws_cli_results/logs"
export aws_cli_input_tmp="${AWS_CLI_SOURCE_SCRIPTS}/aws_cli_results/inputs"
export aws_assume_role_expired_time=55
export aws_tmp_input="/tmp/aws_tmp_input_23647494949484.txt"
# To allow log detail of the aws cli [true|false]
export aws_show_commandline=true
export aws_log_tail_since=120m

mkdir -p ${tmp_credentials}
mkdir -p ${aws_cli_results}
mkdir -p ${aws_cli_logs}
mkdir -p ${aws_cli_input_tmp}

# add some help aliases
alias get-account-alias='aws iam list-account-aliases'
alias get-account-id='echo AccountId $(aws sts get-caller-identity --query "Account" --output text)'

# Import sub-commandline.

for module in $(echo "common services"); do
	for script in $(ls ${AWS_CLI_SOURCE_SCRIPTS}/${module}); do
		source ${AWS_CLI_SOURCE_SCRIPTS}/${module}/$script
	done
done
