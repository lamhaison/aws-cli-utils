#!/bin/bash

#!/bin/bash

###################################################################
# # @version 		1.0.0
# # @script			sqs.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description    Function when working with SQS
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash sqs.sh
###################################################################

function aws_sqs_list() {
	aws_run_commandline "\
		aws sqs list-queues
	"
}

function aws_sqs_get_by_name() {

	# AWS_ACCOUNT_ID is null, get account id and export to ENV environment
	if [[ -z "$AWS_ACCOUNT_ID" ]]; then
		aws_assume_role_get_aws_account_id
	fi

	aws_run_commandline "\
		aws sqs get-queue-attributes \
			--queue-url https://sqs.${AWS_REGION}.amazonaws.com/${AWS_ACCOUNT_ID}/${1:?'queue_name is unset or empty'} \
			--attribute-names All
	"

}

function aws_sqs_get_by_url() {
	aws_run_commandline "\
		aws sqs get-queue-attributes \
			--queue-url ${1:?'queue_url is unset or empty'} \
			--attribute-names All
	"

}

function aws_sqs_get() {
	aws_sqs_get_by_url "$1"
}

function aws_sqs_get_with_hint() {
	aws_sqs_get $(peco_create_menu 'peco_aws_sqs_list')
}

function aws_sqs_purge() { # Be careful when using it, it will delete all the message in queues

	local aws_sqs_queue_url=$1

	# Check input invalid
	if [[ -z "$aws_sqs_queue_url" ]]; then return; fi
	aws_run_commandline "\
		aws sqs purge-queue --queue-url "${aws_sqs_queue_url}"
	"

}

function aws_sqs_purge_with_hint() {
	aws_sqs_purge $(peco_create_menu 'peco_aws_sqs_list')
}
