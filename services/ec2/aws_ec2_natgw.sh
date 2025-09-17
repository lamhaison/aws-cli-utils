#!/bin/bash
###################################################################
# # @version 		1.0.0
# # @script			aws_ec2_natgw.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description	When working with natgw
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash aws_ec2_natgw.sh
# # @date			YYYYMMDD
###################################################################

function aws_ec2_natgw_list() {
    aws_run_commandline '\
        aws ec2 describe-nat-gateways  \
            --query "NatGateways[*].{ID:NatGatewayId, State:State, EIP:NatGatewayAddresses[*].PublicIp, Subnet:SubnetId, VPC:VpcId}" \
            --output table
    '
}
