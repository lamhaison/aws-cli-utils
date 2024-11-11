#!/bin/bash

# AWS rds

aws_rds_list_db_clusters() {
	aws_run_commandline " \
		aws rds describe-db-clusters \
			--query '*[].{ \
		DBClusterIdentifier:DBClusterIdentifier, \
		Status:Status, \
		DBClusterParameterGroup:DBClusterParameterGroup, \
		Endpoint:Endpoint, \
		EndpointReader:ReaderEndpoint, \
		Engine:Engine, \
		EngineVersion:EngineVersion, \
		DBClusterMembers:DBClusterMembers }' \
		--output table
	"
}

aws_rds_list_db_instances() {
	aws_run_commandline " \
		aws rds describe-db-instances \
		--query '*[].{\
			DBClusterIdentifier:DBClusterIdentifier,\
			DBInstanceIdentifier:DBInstanceIdentifier,\
			DBInstanceStatus:DBInstanceStatus,\
			Engine:Engine,Endpoint:Endpoint.Address,\
			DBInstanceClass:DBInstanceClass,\
			Engine:Engine,\
			EngineVersion:EngineVersion,\
			DBParameterGroupName:DBParameterGroups[0].DBParameterGroupName,\
			DBParameterGroupApplyStatus:DBParameterGroups[0].ParameterApplyStatus\
		}' --output table
	"
}

# AWS Parameter groups

aws_rds_list_db_cluster_parameter_groups() {
	aws_run_commandline 'aws rds describe-db-cluster-parameter-groups \
		--query "*[].{DBClusterParameterGroupName:DBClusterParameterGroupName,DBParameterGroupFamily:DBParameterGroupFamily}"'
}

aws_rds_list_db_parameter_groups() {
	aws_run_commandline "aws rds describe-db-parameter-groups \
	--query \"*[].{\
		DBParameterGroupName:DBParameterGroupName,
		DBParameterGroupFamily:DBParameterGroupFamily\
	}\" --output table"
}

aws_rds_get_db_parameter() {
	aws_run_commandline " \
		aws rds describe-db-parameters \
			--db-parameter-group-name ${1:?"db_parameter_group_name is unset or empty"}
	"
}

aws_rds_get_db_parameter_with_hint() {
	aws_rds_get_db_parameter $(echo "$(peco_aws_list_db_parameter_groups)" | peco)

}

aws_rds_get_db_cluster_parameter() {
	db_cluster_parameter_group_name=$1

	echo Get all settings of the db parameter group \
		${db_cluster_parameter_group_name:?"db_cluster_parameter_group_name is unset or empty"}

	aws_run_commandline " \
		aws rds describe-db-cluster-parameters \
			--db-cluster-parameter-group-name ${db_cluster_parameter_group_name}
	"
}

aws_rds_get_db_cluster_parameter_with_hint() {
	aws_rds_get_db_cluster_parameter $(echo "$(peco_aws_list_db_cluster_parameter_groups)" | peco)

}

aws_rds_audit_log_setting() {
	db_cluster_parameter_group_name=$1
	echo Get the audit log settings for the db cluster parameter \
		${db_cluster_parameter_group_name:?"db_cluster_parameter_group_name is unset or empty"}

	aws_run_commandline " \
		aws rds describe-db-cluster-parameters \
				--db-cluster-parameter-group-name ${db_cluster_parameter_group_name} \
				--query 'Parameters[].{ \
					ParameterName:ParameterName,DataType:DataType,ParameterValue:ParameterValue,IsModifiable:IsModifiable \
					} | [?starts_with(ParameterName, \`server_audit_log\`)] | [?IsModifiable == \`true\`]' --output table
	"

}

aws_rds_audit_log_setting_with_hint() {
	aws_rds_audit_log_setting $(echo "$(peco_aws_list_db_cluster_parameter_groups)" | peco)
}

aws_rds_audit_log_disabled() {
	db_cluster_parameter_group_name=$1
	echo Disable audit log for the db cluster parameter \
		${db_cluster_parameter_group_name:?"db_cluster_parameter_group_name is unset or empty"}

	aws_run_commandline \
		"
	aws rds modify-db-cluster-parameter-group \
			--db-cluster-parameter-group-name $db_cluster_parameter_group_name \
			--parameters \"ParameterName=server_audit_logging,ParameterValue=0,ApplyMethod=immediate\" \
				 \"ParameterName=server_audit_logs_upload,ParameterValue=0,ApplyMethod=immediate\"
		"
}

aws_rds_audit_log_disabled_with_hint() {
	aws_rds_audit_log_disabled $(echo "$(peco_aws_list_db_cluster_parameter_groups)" | peco)
}

# RDS snapshots
aws_rds_get_snapshots() {
	aws_run_commandline 'aws rds describe-db-snapshots'
}

aws_rds_create_db_cluster_snapshot() {
	aws_rds_db_cluster_name=$1
	aws_run_commandline \
		"
		aws rds create-db-cluster-snapshot \
		--db-cluster-identifier  ${aws_rds_db_cluster_name:?"aws_rds_db_cluster_name is unset or empty"} \
				--db-cluster-snapshot-identifier ${aws_rds_db_cluster_name}-$(date '+%Y-%m-%d-%H-%M-%S')
		"
}

aws_rds_rm_db_cluster_snapshot() {
	aws_rds_db_cluster_snapshot_name=$1
	aws_run_commandline "\
		aws rds delete-db-cluster-snapshot \
			--db-cluster-snapshot-identifier \
				${aws_rds_db_cluster_snapshot_name:?'aws_rds_db_cluster_snapshot_name is unset or empty'}
	"
}

aws_rds_create_db_cluster_snapshot_with_hint() {
	aws_rds_create_db_cluster_snapshot $(echo "$(peco_aws_list_db_clusters)" | peco)
}

aws_rds_create_db_instance_snapshot() {
	aws_rds_db_instance_name=$1
	aws_run_commandline "\
		aws rds create-db-snapshot \
			--db-instance-identifier ${aws_rds_db_instance_name:?"aws_rds_db_instance_name is unset or empty"} \
			--db-snapshot-identifier ${aws_rds_db_instance_name}-$(date '+%Y-%m-%d-%H-%M-%S')
	"
}

# TODO LATER
aws_rds_share_db_cluster_snapshot_with_other_aws_account() {
	aws_rds_db_cluster_name=$1
	aws_shared_account_id=$2

	aws_run_commandline "\
		aws rds modify-db-cluster-snapshot-attribute \
			--db-cluster-snapshot-identifier ${aws_rds_db_cluster_name} \
			--attribute-name restore --values-to-add ${aws_shared_account_id}   
	"

}

aws_rds_rm_db_snapshot() {
	aws_rds_db_snapshot_name=$1
	aws_run_commandline "\
		aws rds delete-db-snapshot --db-snapshot-identifier \
				${aws_rds_db_snapshot_name:?'aws_rds_db_cluster_snapshot_name is unset or empty'}
	"
}

aws_rds_create_db_instance_snapshot_with_hint() {
	aws_rds_create_db_instance_snapshot $(echo "$(peco_aws_list_db_instances)" | peco)
}

# AWS events
aws_rds_list_events() {
	aws_run_commandline 'aws rds describe-events'

}

# AWS rds reboot

aws_rds_failover_db_cluster() {
	aws_rds_db_cluster_name=$1
	aws_run_commandline \
		"
	aws rds failover-db-cluster \
		--db-cluster-identifier ${aws_rds_db_cluster_name:?'aws_rds_db_cluster_name is unset or empty'}
	"
}

aws_rds_failover_db_cluster_with_hint() {
	aws_rds_db_cluster_name $(echo "$(peco_aws_list_db_clusters)" | peco)
}

aws_rds_reboot_db_instance() {
	aws_rds_db_instance_identifier=$1
	echo Reboot the aws rds db instance ${aws_rds_db_instance_identifier:?"aws_rds_db_instance_identifier is unset or empty"}
	aws_run_commandline "aws rds reboot-db-instance --db-instance-identifier ${aws_rds_db_instance_identifier}"
}

aws_rds_reboot_db_instance_with_hint() {
	aws_rds_reboot_db_instance $(echo "$(peco_aws_list_db_instances)" | peco)
}

# AWS upgrade from aurora-1 to aurora-2
aws_help_rds_upgrade_aurora_1_to_aurora_2() {
	echo \
		"
		Here is the strcuture of the commandline \

		aws rds modify-db-cluster \
			--db-cluster-identifier DB_CLUSTER_NAME \
			--db-instance-parameter-group-name DB_PARAMETER_GROUP_NAME \
			--db-cluster-parameter-group-name DB_CLUSTER_PARAMETER_GROUP_NAME \
			--engine-version 5.7.mysql_aurora.2.10.2 \
			--allow-major-version-upgrade \
			--apply-immediately
	"
}

aws_rds_list_db_cluster_snapshots() {
	aws_run_commandline " \
		aws rds describe-db-cluster-snapshots \
			--include-shared \
			--query 'DBClusterSnapshots[].{\
				DBClusterSnapshotIdentifier:DBClusterSnapshotIdentifier,\
				DBClusterIdentifier:DBClusterIdentifier,\
				SnapshotCreateTime:SnapshotCreateTime,\
				Status:Status,SnapshotType:SnapshotType}' \
			--output table
	"

}

function aws_rds_list_db_snapshots() {
	aws_run_commandline " \
		aws rds describe-db-snapshots \
			--include-shared \
			--query 'DBSnapshots[].{\
				DBSnapshotIdentifier:DBSnapshotIdentifier,\
				DBIdentifier:DBClusterIdentifier,\
				SnapshotCreateTime:SnapshotCreateTime,\
				Status:Status,SnapshotType:SnapshotType}' \
			--output table
	"

}

aws_rds_rm_db_instance_instruction() {
	aws_rds_db_instance_name=$1

	aws_commandline_logging " \
		aws rds modify-db-instance \
			--db-instance-identifier ${aws_rds_db_instance_name:-"\$aws_rds_db_instance_name"} \
			--apply-immediately \
			--no-deletion-protection
	"

	aws_commandline_logging " \
		aws rds delete-db-instance \
			--db-instance-identifier ${aws_rds_db_instance_name:-"\$aws_rds_db_instance_name"} \
			--skip-final-snapshot
	"
}

function aws_rds_list_pending_maintenance_actions { # To check security update for rds

	local aws_rds_db_instance_name=$1

	local cmd="aws rds describe-pending-maintenance-actions"

	if [[ ! -z "$aws_rds_db_instance_name" ]]; then
		aws_account_info # To get account id
		cmd+=" --resource-identifier arn:aws:rds:${AWS_REGION}:${AWS_ACCOUNT_ID}:db:${aws_rds_db_instance_name}"
	fi

	aws_run_commandline "${cmd}"

}

function aws_rds_list_pending_maintenance_actions_with_hint() {

	local aws_rds_db_instance_name=$(peco_create_menu 'peco_aws_list_db_instances' '--prompt "Choose db instance name >"')

	aws_rds_list_pending_maintenance_actions "${aws_rds_db_instance_name}"
}
