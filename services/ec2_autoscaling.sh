aws_autoscaling_list() {
	aws_run_commandline 'aws autoscaling describe-auto-scaling-groups'
}

aws_autoscaling_get() {
	aws_autoscaling_name=$1

	aws_run_commandline \
		"
		aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names ${aws_autoscaling_name:?'aws_autoscaling_name is unset or empty'} \
        --query \"AutoScalingGroups[0]\" \
        --output table
	"
}

aws_autoscaling_get_instances() {
	aws_autoscaling_name=$1

	aws_run_commandline \
		"
		aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names ${aws_autoscaling_name:?'aws_autoscaling_name is unset or empty'} \
        --query \"AutoScalingGroups[0].Instances[*].{InstanceId:InstanceId,HealthStatus:HealthStatus,AvailabilityZone:AvailabilityZone,LifecycleState:LifecycleState,LaunchTemplate:LaunchTemplate.Version}\" \
        --output table
	"
}

aws_autoscaling_get_with_hint() {
	aws_autoscaling_get $(peco_create_menu 'peco_aws_autoscaling_list')
}

aws_autoscaling_get_instances_with_hint() {
	aws_autoscaling_get_instances $(peco_create_menu 'peco_aws_autoscaling_list')
}

aws_autoscaling_set_desired_capacity() {
	aws_autoscaling_name=$1
	aws_autoscaling_desized_capacity=$2

	aws_run_commandline \
		"
		aws autoscaling set-desired-capacity \
    		--auto-scaling-group-name ${aws_autoscaling_name} \
    		--desired-capacity ${aws_autoscaling_desized_capacity}
	"

}

aws_autoscaling_detach_instance() {
	aws_autoscaling_name=$1
	aws_ec2_instance_id=$2

	aws_run_commandline \
		"
		aws autoscaling detach-instances \
    		--auto-scaling-group-name ${aws_autoscaling_name} \
    		--instance-ids ${aws_ec2_instance_id} \
    		--no-should-decrement-desired-capacity
	"
}

aws_autoscaling_set_desired_capacity_with_hint() {
	aws_autoscaling_name=$(peco_create_menu 'peco_aws_autoscaling_list')
	aws_autoscaling_desized_capacity=$(peco_create_menu_with_array_input "0 1 2 3 4 5 6 7 8 9 10" | peco)

	aws_autoscaling_set_desired_capacity ${aws_autoscaling_name} ${aws_autoscaling_desized_capacity}
}

# TODO LATER
aws_autoscaling_detach_instance_with_hint() {
	echo "TODO Later"
}

aws_autoscaling_get_launching_template() {
	aws_autoscaling_launching_template_id=$1
	aws_run_commandline "\
		aws ec2 describe-launch-templates \
			--launch-template-ids ${aws_autoscaling_launching_template_id}
	"
}

aws_autoscaling_get_launching_template_version() {

	aws_autoscaling_launching_template_id=$1
	# aws_autoscaling_launching_template_version=$2
	aws_run_commandline "\
		aws ec2 describe-launch-template-versions \
			--launch-template-id ${aws_autoscaling_launching_template_id}
	"

}
