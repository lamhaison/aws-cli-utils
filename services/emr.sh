#!/bin/bash

aws_emr_list() {
	aws_run_commandline "\
		aws emr list-clusters \
			--active 
	"
}

aws_emr_get() {
	aws_emr_cluster_id=$1
	aws_run_commandline "\
		aws emr describe-cluster \
			--cluster-id ${aws_emr_cluster_id:?'aws_emr_cluster_id is unset or empty'}
	"
}

aws_emr_info() {

	for aws_emr_cluster_id in $(aws emr list-clusters --active --query "Clusters[].Id" --output text); do
		aws_emr_get ${aws_emr_cluster_id}
	done

}
