#!/bin/bash
# AWS codebuild

aws_codebuild_list() {
	aws_run_commandline "aws codebuild list-projects"
}
aws_codebuild_get_latest_build() {
	aws_codebuild_project_name=$1
	aws codebuild batch-get-builds --ids $(aws codebuild list-builds-for-project --project-name $aws_codebuild_project_name --query "*[] | [1]" | awk -F '"' '{print $2}')
}

aws_codebuild_get_latest_build_with_hint() {
	echo "List codebuilds"
	aws codebuild list-projects
	echo "Your codebuild >"
	read aws_codebuild_project_name
	aws_codebuild_get_latest_build $aws_codebuild_project_name

}

aws_codebuild_start() {
	aws_codebuild_project_name=$1
	echo Start the project name ${aws_codebuild_project_name:?"Project name is unset or empty"}
	aws codebuild start-build --project-name ${aws_codebuild_project_name}
}

aws_codebuild_start_with_hint() {
	echo "List codebuilds"
	aws codebuild list-projects
	echo "Your codebuild >"
	read aws_codebuild_project_name
	aws_codebuild_start $aws_codebuild_project_name

}

aws_codebuild_check_vcs_repos() {
	for project in $(aws codebuild list-projects --query "*[]" --output text); do
		echo "Project ${project}"
		aws codebuild batch-get-projects --names ${project} --query "*[].source.{type:type,location:location}"
	done
}
