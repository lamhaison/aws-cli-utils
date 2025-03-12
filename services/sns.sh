#!/bin/bash

###################################################################
# # @script			aws_sns.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
###################################################################

function aws_sns_list() {
	aws_run_commandline "\
		aws sns list-topics	
	"
}

function aws_sns_get() {

	local aws_sns_arn=$1

	# Check input invalid
	if [[ -z "$aws_sns_arn" ]]; then return; fi
	aws_run_commandline "\
		aws sns get-topic-attributes --topic-arn ${aws_sns_arn}
	"
}

function aws_sns_get_with_hint() {

	local aws_sns_arn=$(peco_create_menu 'peco_aws_sns_list' '--prompt "Choose sns arn >"')
	aws_sns_get $aws_sns_arn
}

function aws_sns_list_subscriptions() {
	local aws_sns_arn=$1

	# Check input invalid
	if [[ -z "$aws_sns_arn" ]]; then return; fi
	aws_run_commandline "\
		aws sns list-subscriptions-by-topic --topic-arn ${aws_sns_arn}
	"
}

function aws_sns_list_subscriptions_with_hint() {
	local aws_sns_arn=$(peco_create_menu 'peco_aws_sns_list' '--prompt "Choose sns arn >"')
	aws_sns_list_subscriptions "${aws_sns_arn}"
}

function aws_sns_push_message() {
	local aws_sns_arn=$1
	local message=$2

	# Check input invalid
	if [[ -z "$aws_sns_arn" ]]; then return; fi
	if [[ -z "$message" ]]; then return; fi

	aws_run_commandline "aws sns publish --topic-arn "${aws_sns_arn}" --message '${message}'"

}

function aws_sns_push_message_hello_world() { # For testing
	aws_sns_push_message "$1" "Hello World!"
}

function aws_sns_push_message_hello_world_with_hint() {
	local aws_sns_arn=$(peco_create_menu 'peco_aws_sns_list' '--prompt "Choose sns arn >"')
	aws_sns_push_message "${aws_sns_arn}" "Hello World!"
}
