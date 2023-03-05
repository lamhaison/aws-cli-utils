#!/bin/bash

aws_eks_get_kube_config() {
	aws eks update-kubeconfig \
		--name ${1:?'aws_eks_cluster_name is unset or empty'}
}
