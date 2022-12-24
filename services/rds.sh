#!/bin/bash

# AWS rds


aws_rds_list_db_clusters() {
	aws rds describe-db-clusters  --query "*[].{DBClusterIdentifier:DBClusterIdentifier,DBClusterMembers:DBClusterMembers}"
}

aws_rds_list_db_cluster_parameter_groups() {
	aws rds describe-db-cluster-parameter-groups --query "*[].DBClusterParameterGroupName"
}

aws_rds_list() {
	aws rds describe-db-clusters --query "*[].DBClusterMembers" --output table
}



aws_rds_create_cluster_snapshot() {
        aws_rds_db_cluster_name=$1
        aws rds create-db-cluster-snapshot \
		--db-cluster-identifier  ${aws_rds_db_cluster_name} \
                --db-cluster-snapshot-identifier ${aws_rds_db_cluster_name}-`date '+%Y-%m-%d-%H-%M-%S'`
}


aws_rds_create_instance_snapshot() {
	aws_rds_db_instance_name=$1
	aws rds create-db-snapshot \
    		--db-instance-identifier ${aws_rds_db_instance_name} \
    		--db-snapshot-identifier ${aws_rds_db_instance_name}-`date '+%Y-%m-%d-%H-%M-%S'`
}

aws_rds_audit_log_setting() {
	db_cluster_parameter_group_name=$1
	aws rds describe-db-cluster-parameters \
    		--db-cluster-parameter-group-name ${db_cluster_parameter_group_name} \
    		--query 'Parameters[].{ParameterName:ParameterName,DataType:DataType,ParameterValue:ParameterValue,IsModifiable:IsModifiable} | [?starts_with(ParameterName, `server_audit_log`)] | [?IsModifiable == `true`]'

}

aws_rds_audit_log_disabled () {
	db_cluster_parameter_group_name=$1
	
	aws rds modify-db-cluster-parameter-group \
    		--db-cluster-parameter-group-name $db_cluster_parameter_group_name \
    		--parameters "ParameterName=server_audit_logging,ParameterValue=0,ApplyMethod=immediate" \
                 "ParameterName=server_audit_logs_upload,ParameterValue=0,ApplyMethod=immediate"
}