#!/bin/bash

###################################################################
# # @script			script_name.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
###################################################################

function aws_scp_list_policies() {
	aws organizations list-policies --filter SERVICE_CONTROL_POLICY
}

function aws_scp_policies_info() { # To share with third-party

	for policy_id in $(aws organizations list-policies --filter SERVICE_CONTROL_POLICY --query "Policies[*].Id" --output text); do
		echo "Policy ID: $policy_id"
		aws organizations describe-policy --policy-id $policy_id --query "Policy.Content" --output json
		echo "------------------------------"
	done

}
