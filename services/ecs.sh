aws_ecs_list_clusters() {
	aws_run_commandline "aws ecs list-clusters"
}

aws_ecs_list_services() {
	aws_ecs_cluster_arn=$1
	echo List service for the cluster ${aws_ecs_cluster_arn:?"aws_ecs_cluster_arn is not set or empty"}
	aws_run_commandline "aws ecs list-services --cluster $aws_ecs_cluster_arn"
}

aws_ecs_list_services_with_hint() {
	echo "List clusters"
	aws_ecs_cluster_arn=$(echo "$(peco_aws_ecs_list_clusters)" | peco)
	aws_ecs_list_services $aws_ecs_cluster_arn
}

aws_ecs_get_service_command() {
	aws_run_commandline "\
	aws ecs describe-services \
		--cluster $aws_ecs_cluster_arn \
		--services $aws_ecs_service_arn
	"
}

aws_ecs_get_service() {
	aws_ecs_cluster_arn=$1
	aws_ecs_service_arn=$2
	echo Cluster Arn ${aws_ecs_cluster_arn:?"aws_ecs_cluster_arn is not set or empty"}
	echo Service Arn ${aws_ecs_service_arn:?"aws_ecs_service_arn is not set or empty"}
	aws_ecs_get_service_command

}

aws_ecs_get_service_with_hint() {
	echo "List clusters"
	aws_ecs_cluster_arn=$(echo "$(peco_aws_ecs_list_clusters)" | peco)
	echo Cluster Arn ${aws_ecs_cluster_arn:?"aws_ecs_cluster_arn is not set or empty"}
	echo "List services"
	aws_ecs_service_arn=$(echo "$(peco_aws_ecs_list_services)" | peco)
	echo Service Arn ${aws_ecs_service_arn:?"aws_ecs_service_arn is not set or empty"}
	aws_ecs_get_service_command

}

aws_ecs_list_scheduled_actions() {

	aws_run_commandline \
		"
	aws application-autoscaling describe-scheduled-actions \
		--service-namespace ecs
	"
}

aws_ecs_list_scaling_policies() {
	# TODO Later
	aws_run_commandline "\
		aws application-autoscaling describe-scaling-policies \
			--service-namespace ecs --query '*[].Alarms[0].AlarmName' \
			--output text | xargs aws cloudwatch describe-alarms --alarm-names
	"

}

aws_ecs_get_taskdefinition() {
	aws_task_definition_arn=$1
	aws_run_commandline "\
		aws ecs describe-task-definition \
			--task-definition ${aws_task_definition_arn:?'aws_task_definition_arn is unset or empty'}
	"

}

aws_ecs_set_service_desized_count() {
	aws_ecs_service_name=$1
	aws_ecs_cluster_name=$2
	aws_ecs_desized_count=$3
	aws_run_commandline "\
		aws ecs update-service \
			--cluster ${aws_ecs_service_name} \
			--service ${aws_ecs_service_name} \
			--desired-count ${aws_ecs_desized_count}
			
	"
}
