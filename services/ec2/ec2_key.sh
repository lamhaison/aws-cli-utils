#!/bin/bash

###################################################################
# # @version 		1.0.0
# # @script			ec2_key.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description	Description detail about the script
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash ec2_key.sh
# # @date			YYYYMMDD
###################################################################

function aws_ec2_key_list() {
	aws_run_commandline "\
		aws ec2 describe-key-pairs
	"
}

function aws_ec2_key_get() {
	aws_run_commandline "\

		aws ec2 describe-key-pairs --key-names ${1:?'key-pair-name is unset or empty'}

	"
}

function aws_ec2_key_get_public_key() {
	aws_run_commandline "\
		aws ec2 describe-key-pairs \
			--include-public-key \
			--key-names ${1:?'key-pair-name is unset or empty'} 
	"
}
