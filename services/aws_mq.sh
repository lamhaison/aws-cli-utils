#!/bin/bash

###################################################################
# # @version 		1.0.0
# # @script			aws_mq.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description	Description detail about the script
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash aws_mq.sh
###################################################################

function aws_mq_list_broker() {
	aws_run_commandline "\
		aws mq list-brokers   --query '*[].{BrokerName:BrokerName,BrokerState:BrokerState,DeploymentMode:DeploymentMode,EngineType:EngineType,HostInstanceType:HostInstanceType}' \
		--output table
	"
}

function aws_mq_list_configurations() {
	aws_run_commandline "\
		aws mq list-configurations
	"
}
