lamhaison_help_create_user() {

	echo '

		visudo
		son.lam ALL=(ALL) ALL
		# Define variable
		user_name=son.lam
		sudo_password=xxxx
		public_key="ssh-rsa AAAAB3Nza... ${user_name}"
		useradd ${user_name}

		# Sudo to root account
		echo -e "${user_name}\n${user_name}" | (passwd ${user_name})
		su vltlhson
		mkdir ~/.ssh
		chmod 700 ~/.ssh
		echo "${public_key}" > ~/.ssh/authorized_keys
		chmod 400 -R ~/.ssh/authorized_keys
		exit



	'
}
