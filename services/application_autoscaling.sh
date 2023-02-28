#!/bin/bash

# Setting for ecs
aws_application_autoscaling_ecs_list_scheduled_actions() {
	aws application-autoscaling describe-scheduled-actions \
		--service-namespace ecs
}
