#!/bin/bash

aws_codepipeline_list() {
	aws_run_commandline 'aws codepipeline list-pipelines --query "*[].name"'
}

aws_codepipeline_get_latest_execution_with_hint() {

	echo "List pipelines"
	aws codepipeline list-pipelines --query "*[].name"

	echo "Your pipeline >"
	read codepipeline_name
	aws_codepipeline_get_latest_execution $codepipeline_name
}

aws_codepipeline_get_latest_execution() {

	codepipeline_name=$1
	aws codepipeline list-action-executions --pipeline-name $codepipeline_name --filter pipelineExecutionId=$(aws codepipeline list-pipeline-executions --pipeline-name $codepipeline_name --query "*[0].pipelineExecutionId" --output text) --output table
}
