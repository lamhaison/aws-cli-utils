aws_help_install_mysql_client_5_7() {

	echo \
		"
		sudo rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
		rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
		yum install -y mysql-community-client
	"
}
