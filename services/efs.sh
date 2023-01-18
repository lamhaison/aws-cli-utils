#!/bin/bash

aws_efs_list() {
	aws_run_commandline \
		"
		aws efs describe-file-systems \
			--query '*[].{FileSystemId:FileSystemId,Name:Name,\
				ThroughputMode:ThroughputMode,PerformanceMode:PerformanceMode}' \
			--output table
	"
}
