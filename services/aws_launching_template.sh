#!/bin/bash

###################################################################
# # @version 		1.0.0
# # @script			aws_lanching_template.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description	Working with launching template
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash aws_lanching_template.sh
# # @date			YYYYMMDD
###################################################################

function aws_autoscaling_list_launching_templates() {
	aws_run_commandline "\
		aws ec2 describe-launch-templates  --query '*[].{Id:LaunchTemplateId,LaunchTemplateName:LaunchTemplateName,ZCreatedBy:CreatedBy}' \
		--output table
	"
}

function aws_autoscaling_get_launching_template() {
	aws_autoscaling_launching_template_id=$1
	aws_run_commandline "\
		aws ec2 describe-launch-templates \
			--launch-template-ids ${aws_autoscaling_launching_template_id}
	"
}

function aws_autoscaling_get_launching_template_version() {

	aws_autoscaling_launching_template_id=$1
	# aws_autoscaling_launching_template_version=$2
	aws_run_commandline "\
		aws ec2 describe-launch-template-versions \
			--launch-template-id ${aws_autoscaling_launching_template_id}
	"

}
