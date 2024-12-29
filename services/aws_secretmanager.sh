#!/bin/bash

###################################################################
# # @script			aws_secret_manager.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
###################################################################

function aws_secretmanager_list() {
	aws_run_commandline "\
		aws secretsmanager list-secrets \
		--query '*[].{Name:Name,Description:Description}' \
		--output table
	"
}

function aws_secretmanager_get_value() {

	local secret_name=$1
	# Check input invalid
	if [[ -z "$secret_name" ]]; then return; fi

	aws_run_commandline "\
		aws secretsmanager get-secret-value \
			--secret-id "${secret_name}"
	"
}

function aws_secretmanager_get_value_with_hint() {
	local secret_name=$(peco_create_menu 'peco_aws_secretmanager_list' '--prompt "Choose secret that you want >"')
	aws_secretmanager_get_value "${secret_name}"
}
