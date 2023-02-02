#!/bin/bash

# Remove duplicate rows.
aws_batch_list_jobs() {
	aws_run_commandline "\
		aws batch describe-job-definitions \
			--query '*[].{jobDefinitionName:jobDefinitionName}' --output table | uniq
	"
}

aws_batch_get_job() {

	aws_job_definition_name=$1
	aws_run_commandline "\
		aws batch describe-job-definitions --job-definition-name \
			${aws_job_definition_name:?'aws_job_definition_name is unset or empty'}
	"

}
