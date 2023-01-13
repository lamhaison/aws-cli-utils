#!/bin/bash

aws_codepipeline_list() {
	aws_run_commandline 'aws codepipeline list-pipelines --query "*[].name"'
}

aws_codepipeline_get_latest_execution_with_hint() {
	aws_codepipeline_get_latest_execution $(echo "$(peco_aws_codepipeline_list)" | peco)
}

aws_codepipeline_get_latest_execution() {

	codepipeline_name=$1
	aws_codepipeline_execution_id_latest=$(
		aws codepipeline list-pipeline-executions \
			--pipeline-name ${codepipeline_name:?'codepipeline_name is unset or empty'} \
			--query 'pipelineExecutionSummaries[0].pipelineExecutionId' \
			--output text | head -1
	)
	aws_run_commandline \
		"
		aws codepipeline list-action-executions \
			--pipeline-name ${codepipeline_name:?'codepipeline_name is unset or empty'} \
			--filter pipelineExecutionId=${aws_codepipeline_execution_id_latest:?'aws_codepipeline_execution_id_latest is unset or empty'} \
			--output table
	"

}
