#!/bin/bash

import_tmp_credential() {
	eval $(unzip -p -P $assume_role_password_encrypted ${tmp_credentials}/${ASSUME_ROLE}.zip)
	aws_export_region
}

zip_tmp_credential() {
	cd $tmp_credentials
	echo "Encrypt temporary credential for assume-role ${ASSUME_ROLE} at ${tmp_credentials}/${ASSUME_ROLE}.zip"

	if [ -f "${tmp_credentials}/${ASSUME_ROLE}.zip" ]; then
		rm -rf ${tmp_credentials}/${ASSUME_ROLE}.zip
	fi

	zip -q -P $assume_role_password_encrypted $ASSUME_ROLE.zip $ASSUME_ROLE && rm -rf $ASSUME_ROLE
	cd -
}

aws_assume_role_unzip_tmp_credential() {
	cd $tmp_credentials
	assume_role_name=$1
	rm -rf ${assume_role_name}
	unzip -P $assume_role_password_encrypted ${assume_role_name}.zip
	echo "You credential is save here ${tmp_credentials}/${assume_role_name}"
	cd -
}

aws_assume_role_remove_tmp_credential() {
	assume_role_name_input=$1
	tmp_credentials_file_zip=${tmp_credentials}/${assume_role_name_input}.zip
	if [ -f "${tmp_credentials_file_zip}" ]; then
		rm -r ${tmp_credentials_file_zip}
	fi
}

aws_export_region() {
	AWS_REGION=$(aws configure get profile.${ASSUME_ROLE}.region)
	export AWS_REGION=$AWS_REGION
}

aws_assume_role_get_credentail() {
	tmp_credentials_file="${tmp_credentials}/${ASSUME_ROLE}"
	echo "Running assume-role ${ASSUME_ROLE}"
	echo "Remove the credential ${tmp_credentials_file}"
	rm -rf ${tmp_credentials_file}
	assume-role ${ASSUME_ROLE} >${tmp_credentials_file}
	empty_file=$(find ${tmp_credentials} -name ${ASSUME_ROLE} -empty)
	if [ -z "${empty_file}" ]; then
		zip_tmp_credential
	else
		echo "Assume role couldn't be succesful"
		rm -rf ${tmp_credentials_file}
	fi

}

aws_call_assume_role() {
	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN ASSUMED_ROLE
	tmp_credentials_file="${tmp_credentials}/${ASSUME_ROLE}"
	tmp_credentials_file_zip="${tmp_credentials}/${ASSUME_ROLE}.zip"

	if [ -f ${tmp_credentials_file_zip} ]; then

		valid_file=$(find ${tmp_credentials} -name ${ASSUME_ROLE}.zip -mmin +${aws_assume_role_expired_time})
		empty_file=$(find ${tmp_credentials} -name ${ASSUME_ROLE}.zip -empty)
		# Don't find any file is older than expired-time
		if [ -z "${valid_file}" ] && [ -z "${empty_file}" ]; then
			echo "Re-use the temporary credential of ${ASSUME_ROLE} at ${tmp_credentials_file_zip}"
		else
			echo "The credential is older than ${aws_assume_role_expired_time} or the credential is empty then we will run assume-role ${ASSUME_ROLE} again"
			aws_assume_role_get_credentail
		fi
	else
		aws_assume_role_get_credentail
	fi
	import_tmp_credential

}

aws_assume_role_set_name() {
	aws_assume_role_name=$1
	echo You set the assume role name ${aws_assume_role_name:?"The assume role name is unset or empty"}

	export ASSUME_ROLE=${aws_assume_role_name}
	export assume_role=${aws_assume_role_name}
	# export ASSUMED_ROLE=${aws_assume_role_name}
	aws_call_assume_role

	tmp_credentials_file_zip="${tmp_credentials}/${ASSUME_ROLE}.zip"
	if [ -f $tmp_credentials_file_zip ]; then
		cd ${aws_cli_results}
		aws_account_infos
	else
		echo "Please try again, the assume role action was not complete"
	fi

	echo "You are using the assume role name ${ASSUME_ROLE}"
}

aws_assume_role_set_name_with_hint() {

	# # cat ~/.aws/config |grep profile |grep -v "source"
	# peco_assume_role_name
	# echo "Please input your assume role name >"
	# read  assume_role_name
	# aws_assume_role_set_name $assume_role_name
	# echo "You are using the profile ${ASSUME_ROLE}"

	aws_assume_role_set_name_with_hint_peco
}

aws_assume_role_set_name_with_hint_peco() {

	echo "Please input your assume role name >"
	assume_role_name=$(grep -iE "\[*\]" ~/.aws/config | tr -d "[]" | awk -F " " '{print $2}' | peco)
	aws_assume_role_set_name $assume_role_name

}

aws_account_infos() {
	get-account-alias
	get-account-id
	echo AWS Region ${AWS_REGION:?"The AWS_REGION is unset or empty"}
}
