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
	aws_ecs_cluster_arn=$(aws ecs list-clusters --query "*[]" --output text | tr "\t" "\n" | peco)
	aws_ecs_list_services $aws_ecs_cluster_arn
}

aws_ecs_get_service_command() {
	aws_run_commandline "aws ecs describe-services --cluster $aws_ecs_cluster_arn --services $aws_ecs_service_arn"
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

aws_ecs_get_scheduled_actions() {

	aws_run_commandline \
		"
	aws application-autoscaling describe-scheduled-actions \
		--service-namespace ecs
	"
}
