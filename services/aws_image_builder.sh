#!/bin/bash

###################################################################
# # @version 		1.0.0
# # @script			images_builder.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description	Working with image builder
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash images_builder.sh
###################################################################

function lhs_imagebuilder_list() {
	aws_run_commandline "\
		aws imagebuilder list-image-pipelines
	"
}

function lhs_imagebuilder_get() {
	aws_run_commandline "\
		aws imagebuilder get-image-pipeline \
			--image-pipeline-arn  ${1:?'image_pipeline_arn is unset or empty'}
	"
}

function lhs_imagebuilder_get_with_hint() {
	lhs_imagebuilder_get $(peco_create_menu 'peco_aws_imagebuilder_list' '--prompt "Image Pipelines >"')

}

function lhs_imagebuilder_list_recipes() {
	aws_run_commandline "\
		aws imagebuilder list-image-recipes
	"
}

function lhs_imagebuilder_get_recipe() {
	aws_run_commandline "\
		aws imagebuilder get-image-recipe --image-recipe-arn  \
			${1:?'image_recipe_arn is unset or empty'}
	"
}

function lhs_imagebuilder_get_recipe_with_hint() {
	lhs_imagebuilder_get_recipe $(peco_create_menu 'peco_aws_imagebuilder_list_recipes' '--prompt "Choose recipes >"')
}
