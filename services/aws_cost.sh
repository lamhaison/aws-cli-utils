#!/bin/bash

###################################################################
# # @version 		1.0.0
# # @script			aws_cost.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
# # @description	Description detail about the script
# # @bash_version   None
# # @notes          None
# # @usage		 	Only use function in the script instead of bash aws_config.sh
# # @date			YYYYMMDD
###################################################################

function aws_cost_list_months_later() {
    # Default is 6 months
    local months=${1:-'6'}
    aws ce get-cost-and-usage \
        --time-period "Start=$(date -d "${months} months ago" +%Y-%m-01),End=$(date -d "$(date +%Y-%m-01) -1 day" +%Y-%m-%d)" \
        --granularity MONTHLY --metrics "UnblendedCost"
}

function aws_cost_get_current_month() {
    aws ce get-cost-and-usage \
        --time-period "Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d)" \
        --granularity MONTHLY --metrics "UnblendedCost"
}

function aws_cost_get_last_month() {
    aws ce get-cost-and-usage \
        --time-period "Start=$(date -d "$(date +%Y-%m-01) -1 month" +%Y-%m-01),End=$(date -d "$(date +%Y-%m-01) -1 day" +%Y-%m-%d)" \
        --granularity MONTHLY --metrics "UnblendedCost"
}

function aws_cost_get_service_cost_current_month() {
    aws ce get-cost-and-usage \
    --time-period Start=$(date +%Y-%m-01),End=$(date -d "+1 day" +%Y-%m-%d) \
    --granularity MONTHLY \
    --metrics "UnblendedCost" \
    --group-by Type=DIMENSION,Key=SERVICE \
    --output table
}

function aws_cost_get_last_7_days() {
    aws ce get-cost-and-usage \
        --time-period "Start=$(date -d "7 days ago" +%Y-%m-%d),End=$(date +%Y-%m-%d)" \
        --granularity DAILY --metrics "UnblendedCost" \
        --output table 
}
