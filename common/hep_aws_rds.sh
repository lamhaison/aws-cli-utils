aws_help_install_mysql_client_5_7() {

	echo \
		"
		sudo rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
		rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
		yum install -y mysql-community-client
	"
}

aws_help_rds_list_bin_logs() {
	echo \
		"show binary logs;"
}

aws_help_rds_start_stop_replication() {
	echo "CALL mysql.rds_start_replication;"
	echo "show slave status\G;"
	echo "CALL mysql.rds_stop_replication;"
	echo "show slave status\G;"
}

aws_help_rds_aurora_set_replication() {
	echo \
		"
		aws_rds_list_events
		CALL mysql.rds_set_external_master ('master_address', 3306, \
			'repl_user', '123456', 'mysql-bin-changelog.000002', 1234, 0);
	"
}

aws_help_rds_aurora_test_replication() {

	echo \
		"

		# On master
		CREATE TABLE IF NOT EXISTS tasks (
    		task_id INT AUTO_INCREMENT PRIMARY KEY
		)  ENGINE=INNODB;

		DB_USER=xxx
		DB_PASSWD=xxx
		DB_NAME=xxx
		DB_ADDRESS=xxx
		mysql --user=$DB_USER --password=$DB_PASSWD $DB_NAME -h $DB_ADDRESS << EOF
    		INSERT INTO tasks (\`task_id\`) VALUES (NULL);
		EOF

		# On slave
		select * from tasks;
	"
}
