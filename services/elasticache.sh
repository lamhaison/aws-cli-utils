#!/bin/bash

aws_elasticache_list() {
	aws_run_commandline "\
		aws elasticache describe-cache-clusters --query '*[].{CacheClusterId:CacheClusterId,CacheNodeType:CacheNodeType,Engine:Engine,EngineVersion:EngineVersion,CacheClusterStatus:CacheClusterStatus,NumCacheNodes:NumCacheNodes}' \
		--output table
	"

}

aws_elasticache_rm_redis_cluster_instruction() {
	aws_elasticache_redis_cluster_name=$1

	echo "\
		aws elasticache delete-replication-group 
			--replication-group-id ${aws_elasticache_redis_cluster_name:?'aws_elasticache_redis_cluster_name is unset or empty'}"
}
