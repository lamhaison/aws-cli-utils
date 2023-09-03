#!/bin/bash

###################################################################
# # @version 		Version
# # @script			script_name.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description	Description detail about the script
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash script_name.sh
# # @date			YYYYMMDD
# # @args
# # # $1:  the first argument
###################################################################

function aws_budgets_list() {
	aws_assume_role_get_aws_account_id
	aws_run_commandline "\
		aws budgets describe-budgets --account-id=${AWS_ACCOUNT_ID} 
	"
}

function aws_budget_list_notifiction_for_budget() {

	aws_assume_role_get_aws_account_id

	local budget_name=$1
	# Check input invalid
	if [ -z "$budget_name" ]; then return; fi

	aws_run_commandline "\
		aws budgets describe-notifications-for-budget --account-id=${AWS_ACCOUNT_ID} --budget-name=${budget_name}
	"

}

function aws_budget_list_notifiction_for_budget_with_hint() {
	local lhs_input=$(peco_create_menu 'peco_aws_budgets_list' '--prompt "Choose Budget name >"')
	aws_budget_list_notifiction_for_budget ${lhs_input}
}
