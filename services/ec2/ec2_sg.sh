# Security group
aws_sg_list() {
	aws_run_commandline "\
		aws ec2 describe-security-groups
	"
}

function aws_sg_list_unused() {
	local check_result
	for sg_id in $(aws ec2 describe-security-groups --query 'SecurityGroups[].GroupId' --output text); do
		check_result=$(aws ec2 describe-network-interfaces --filters Name=group-id,Values=${sg_id} --query '*[]')
		# echo "Check check_result: ${sg_id} ${check_result}"
		if [[ "${check_result}" == "[]" ]]; then
			echo "The security is not used ${sg_id}"
			aws_sg_get ${sg_id}
		fi
	done
}

function lhs_sg_list_used() {
	local check_result
	for sg_id in $(aws ec2 describe-security-groups --query 'SecurityGroups[].GroupId' --output text); do
		check_result=$(aws ec2 describe-network-interfaces --filters Name=group-id,Values=${sg_id} --query '*[]')
		# echo "Check check_result: ${sg_id} ${check_result}"
		if [[ ! "${check_result}" == "[]" ]]; then
			echo "The security group is used ${sg_id}"
			aws_network_interface_get "${sg_id}"
		fi

	done

}

function aws_sg_get() {
	aws_sg_id=$1

	aws_run_commandline "\
		aws ec2 describe-security-groups \
    		--group-ids ${aws_sg_id:?'aws_sg_id is unset or empty'}
	"
}

function aws_sg_add_rule_instruction() {
	aws_sg_id=$1

	echo "\
		# Allow access the ssh from a specific IP address
		aws ec2 authorize-security-group-ingress \
		--group-id ${aws_sg_id:-"\$aws_sg_id"} \
		--protocol tcp --port 22 \
		--cidr $(dig +short myip.opendns.com @resolver1.opendns.com)/32
	"
}
