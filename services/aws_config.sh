#!/bin/bash

###################################################################
# # @version 		1.0.0
# # @script			aws_config.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description	Description detail about the script
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash aws_config.sh
# # @date			YYYYMMDD
###################################################################

function aws_config_list_rules() {
	aws_run_commandline "\
		aws configservice describe-config-rules
	"
}
