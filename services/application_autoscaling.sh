#!/bin/bash

# Setting for ecs
aws_application_autoscaling_ecs() {
	aws application-autoscaling describe-scheduled-actions \
		--service-namespace ecs --region ap-northeast-1
}
