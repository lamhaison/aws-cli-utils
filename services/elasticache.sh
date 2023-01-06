#!/bin/bash

aws_elasticache_list() {
	aws_run_commandline 'aws elasticache describe-cache-clusters'
}
