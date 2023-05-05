#!/bin/bash

###################################################################
# # @version 		1.0.0
# # @script			dynamodb.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description	functions when working with aws dynamodb
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash dynamodb.sh
# # @date			20230405
###################################################################

aws_dynamodb_list_tables() {
	aws_run_commandline "
		aws dynamodb list-tables
	"
}

aws_dynamodb_get_table() {

	aws_run_commandline "
		aws dynamodb describe-table --table-name \
			${1:?'dynamodb_table_name is unset or empty'}
	"
}

aws_dynamodb_get_table_with_hint() {
	local lhs_input=$(peco_create_menu 'peco_aws_dynamodb_list_tables' '--prompt "Choose your table >"')
	aws_dynamodb_get_table ${lhs_input}
}
