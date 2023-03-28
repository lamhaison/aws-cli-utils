#!/bin/bash

###################################################################
# # @version 		1.0
# # @script			medibaconvert.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description	List functions for working with mediaconvert aws service
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash medibaconvert.sh
# # @date			20230326
###################################################################

aws_mediaconvert_list_endpoints() {

	aws_run_commandline "\
		aws mediaconvert describe-endpoints
	"

}

private_aws_mediaconvert_get_endpoint() {
	aws mediaconvert describe-endpoints --query '*[] | [0].Url' --output text
}

aws_mediaconvert_list_jobs() {

	local mediaconvert_endpoint=$(private_aws_mediaconvert_get_endpoint)

	aws_run_commandline "\
		aws mediaconvert list-jobs \
			--endpoint-url ${mediaconvert_endpoint} \
			--query '*[].{Id:Id,CreatedAt:CreatedAt,Status:Status}' \
			--output table
	"

}
