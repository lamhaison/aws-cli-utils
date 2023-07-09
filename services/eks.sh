#!/bin/bash

aws_eks_get_kube_config() {
	aws eks update-kubeconfig \
		--name ${1:?'aws_eks_cluster_name is unset or empty'}
}

aws_eks_list_clusters() {
	aws_run_commandline "\
		aws eks list-clusters
	"
}

aws_eks_get_cluster() {
	aws_run_commandline "\
		aws eks describe-cluster --name ${1:?'cluster_name is unset or empty'}
	"
}

aws_eks_get_cluster_with_hint() {
	aws_eks_get_cluster $(peco_create_menu 'peco_aws_eks_list_clusters')
}

aws_eks_get_pod_number_limit_by_instance_type() {
	curl --silent https://raw.githubusercontent.com/awslabs/amazon-eks-ami/master/files/eni-max-pods.txt | peco
}
