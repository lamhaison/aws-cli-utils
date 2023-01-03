#!/bin/bash

aws_events_list() {
	aws_run_commandline "aws events list-rules"
}

aws_events_list_targets () {
	for item in $(aws events list-rules --query "*[].Name" --output text)
	do 
		aws_run_commandline "aws events list-targets-by-rule --rule $item"
	done

}


aws_events_disable_rule() {

	set -e
	set -x
	rule_name=$1

	aws_account_infos	
	echo "Disable rule ${rule_name}"
	aws events describe-rule --name $1
	aws events disable-rule --name $1
	aws events describe-rule --name $1
	
}
