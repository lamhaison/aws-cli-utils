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

aws_assume_role_reset() {
	source ${AWS_CLI_SOURCE_SCRIPTS}/main.sh
}

aws_assume_role_get_current() {
	echo "You are using the assume role name ${ASSUME_ROLE}"
}

aws_assume_role_disable_print_account_info() {
	export aws_assume_role_print_account_info=false
}

aws_assume_role_enable_print_account_info() {
	export aws_assume_role_print_account_info=true
}

aws_assume_role_reuse_current() {
	aws_call_assume_role
}

aws_assume_role_re_use_current() {
	aws_call_assume_role
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
	tmp_credentials_file_zip=${tmp_credentials}/${assume_role_name_input:?"aws_assume_role_remove_tmp_credential is unset or empty"}.zip
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
	# echo "Remove the credential ${tmp_credentials_file}"
	# rm -rf ${tmp_credentials_file} ${tmp_credentials_file}.zip

	assume_role_result=""
	assume_role_duration="$((${aws_assume_role_expired_time} * 60))s"
	while [[ "${assume_role_result}" == "" ]]; do
		assume_role_result=$(assume-role -duration ${assume_role_duration} ${ASSUME_ROLE})

		if [[ "${assume_role_result}" == "" ]]; then
			echo "Assume role couldn't be succesful. Please try again or Ctrl + C to exit"
			sleep 1
		fi
	done

	echo $assume_role_result >${tmp_credentials_file}
	empty_file=$(find ${tmp_credentials} -name ${ASSUME_ROLE} -empty)
	if [ -z "${empty_file}" ]; then
		zip_tmp_credential
	else
		echo "Assume role couldn't be succesful"
		rm -rf ${tmp_credentials_file} ${tmp_credentials_file}.zip
	fi

}

aws_assume_role_is_tmp_credential_valid() {

	local tmp_credentials_file="${tmp_credentials}/${ASSUME_ROLE}"
	local tmp_credentials_file_zip="${tmp_credentials}/${ASSUME_ROLE}.zip"
	local assume_role_duration="$((${aws_assume_role_expired_time} - 5))"

	local valid_file=$(find ${tmp_credentials} -name ${ASSUME_ROLE}.zip -mmin +${assume_role_duration})

	if [[ -n "${valid_file}" ]]; then
		echo -ne "\e]1;AWS-PROFILE[ ${ASSUME_ROLE} ]\a"
		aws_assume_role_re_use_current
	fi

}

aws_call_assume_role() {
	# Do later (Validate the variable of ASSUMED_ROLE before calling assume role)
	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN ASSUMED_ROLE
	tmp_credentials_file="${tmp_credentials}/${ASSUME_ROLE}"
	tmp_credentials_file_zip="${tmp_credentials}/${ASSUME_ROLE}.zip"

	assume_role_duration="$((${aws_assume_role_expired_time} - 5))"
	if [ -f ${tmp_credentials_file_zip} ]; then

		valid_file=$(find ${tmp_credentials} -name ${ASSUME_ROLE}.zip -mmin +${assume_role_duration})
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
		# cd ${aws_cli_results}

		if [ "${aws_assume_role_print_account_info}" = "true" ]; then
			aws_account_infos
		fi
	else
		echo "Please try again, the assume role action was not complete"
	fi

	echo -ne "\e]1;AWS-PROFILE[ ${ASSUME_ROLE} ]\a"
	echo "You are using the assume role name ${ASSUME_ROLE}"
}

aws_assume_role_set_name_with_hint() {
	# set -x
	aws_assume_role_set_name_with_hint_peco
	# set +x
}

aws_assume_role_set_name_with_hint_peco() {
	echo "Please input your assume role name >"
	local assume_role_list=$(grep -iE "\[*\]" ~/.aws/config |
		tr -d "[]" | awk -F " " '{print $2}')

	if [[ -n "${ASSUME_ROLE}" ]]; then
		assume_role_list=$(echo ${assume_role_list} | grep -v ${ASSUME_ROLE})
		assume_role_list=$(echo "${ASSUME_ROLE}\n${assume_role_list}")

	fi

	# local assume_role_name=$(echo "${assume_role_list}" | peco --selection-prefix "Current >")
	local assume_role_name=$(echo "${assume_role_list}" | peco)
	aws_assume_role_set_name $assume_role_name

}

aws_account_infos() {
	get-account-alias

	local aws_account_id=$(aws_run_commandline_with_retry 'aws sts get-caller-identity --query "Account" --output text' "true")
	export AWS_ACCOUNT_ID=$aws_account_id
	echo "AccountId ${AWS_ACCOUNT_ID}"

	echo AWS Region ${AWS_REGION:?"The AWS_REGION is unset or empty"}
}
