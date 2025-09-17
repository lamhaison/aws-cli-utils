#!/bin/bash

import_tmp_credential() {
	eval $(unzip -p -P $assume_role_password_encrypted ${tmp_credentials}/${ASSUME_ROLE}.zip)
	aws_export_region
}

zip_tmp_credential() {
	cd $tmp_credentials >/dev/null
	echo "Encrypt temporary credential for assume-role ${ASSUME_ROLE} at ${tmp_credentials}/${ASSUME_ROLE}.zip"

	if [[ -f "${tmp_credentials}/${ASSUME_ROLE}.zip" ]]; then
		rm -rf ${tmp_credentials}/${ASSUME_ROLE}.zip
	fi

	zip -q -P $assume_role_password_encrypted $ASSUME_ROLE.zip $ASSUME_ROLE && rm -rf $ASSUME_ROLE
	cd - >/dev/null
}

aws_assume_role_reset() {
	source ${AWS_CLI_SOURCE_SCRIPTS}/main.sh
}

aws_assume_role_unset() {

	for var_name in $(echo "ASSUME_ROLE  AWS_ACCESS_KEY_ID \
			AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN AWS_REGION"); do
		unset $var_name
	done
}

aws_assume_role_get_current() {
	echo "You are using the assume role name ${ASSUME_ROLE}"
}

function aws_assume_role_generate_aws_assume_role_link() {

	# To get account id
	local aws_assume_role_account

	local aws_account_alias=$(get-account-alias 2>/dev/null)

	if [[ -z "$aws_account_alias" ]]; then
		# Using account_id
		aws_assume_role_get_aws_account_id
		local aws_assume_role_account="${AWS_ACCOUNT_ID}"

	else
		# Using account_alias
		aws_assume_role_account="${aws_account_alias}"
	fi

	local aws_assume_role_name=$(aws_assume_role_get_role_name)
	echo "https://signin.aws.amazon.com/switchrole?roleName=${aws_assume_role_name}&account=${aws_assume_role_account}"
}

function aws_assume_role_get_role_name() {
	aws sts get-caller-identity --query 'Arn' --output text | awk -F '/' '{ print $2 }'
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
	cd $tmp_credentials >/dev/null
	assume_role_name=$1
	rm -rf ${assume_role_name}
	unzip -P $assume_role_password_encrypted ${assume_role_name}.zip
	echo "You credential is save here ${tmp_credentials}/${assume_role_name}"
	cd - >/dev/null
}

aws_assume_role_rm_tmp_credential() {
	assume_role_name_input=$1
	tmp_credentials_file_zip=${tmp_credentials}/${assume_role_name_input:?"aws_assume_role_rm_tmp_credential is unset or empty"}.zip
	if [[ -f "${tmp_credentials_file_zip}" ]]; then
		rm -r ${tmp_credentials_file_zip}
	fi
}

aws_export_region() {
	AWS_REGION=$(aws configure get profile.${ASSUME_ROLE}.region)
	export AWS_REGION=$AWS_REGION
}

aws_assume_role_get_credential() {
	tmp_credentials_file="${tmp_credentials}/${ASSUME_ROLE}"
	echo "Running assume-role ${ASSUME_ROLE}"
	# echo "Remove the credential ${tmp_credentials_file}"
	# rm -rf ${tmp_credentials_file} ${tmp_credentials_file}.zip

	assume_role_result=""

	aws_assume_role_expired_time_from_config=$(aws configure get profile.${ASSUME_ROLE}.assume_role_timeout)

	# Check input invalid
	if [[ -n "$aws_assume_role_expired_time_from_config" ]]; then
		aws_assume_role_expired_time=$aws_assume_role_expired_time_from_config
	fi

	assume_role_duration="$((${aws_assume_role_expired_time} * 60))s"

	while [[ "${assume_role_result}" == "" ]]; do

		echo "assume-role -duration ${assume_role_duration} ${ASSUME_ROLE}"
		assume_role_result=$(assume-role -duration ${assume_role_duration} ${ASSUME_ROLE})

		if [[ "${assume_role_result}" == "" ]]; then
			echo "Assume role couldn't be succesful. Please try again or Ctrl + C to exit"
			sleep 1
		fi
	done

	echo $assume_role_result >${tmp_credentials_file}
	empty_file=$(find ${tmp_credentials} -name ${ASSUME_ROLE} -empty)
	if [[ -z "${empty_file}" ]]; then
		zip_tmp_credential
	else
		echo "Assume role couldn't be succesful"
		rm -rf ${tmp_credentials_file} ${tmp_credentials_file}.zip
	fi

}

aws_assume_role_unzip_tmp_credential_valid() {
	local aws_assume_role=$1
	local tmp_credentials_file_zip="${tmp_credentials}/${aws_assume_role}.zip"
	local assume_role_duration="$((${aws_assume_role_expired_time} - 5))"

	local expired_tmp_credential=$(find ${tmp_credentials} -name ${aws_assume_role}.zip -mmin +${assume_role_duration})
	# the file aws assume role zip file exists and not empty and not expired
	if [[ -s "${tmp_credentials_file_zip}" ]] && [[ -z "${expired_tmp_credential}" ]]; then
		echo "true"
	else
		echo "false"
	fi

}

aws_assume_role_load_current_assume_role_for_new_tab() {

	local aws_assume_role=$(cat ${aws_cli_current_assume_role_name})
	local tmp_credentials_file_zip="${tmp_credentials}/${aws_assume_role}.zip"
	local assume_role_duration="$((${aws_assume_role_expired_time} - 5))"

	if [[ "true" = "${aws_cli_load_current_assume_role}" ]] &&
		# the file current aws assume role exists
		[[ -s "${aws_cli_current_assume_role_name}" ]] &&
		[[ "true" = "$(aws_assume_role_unzip_tmp_credential_valid ${aws_assume_role})" ]]; then
		aws_assume_role_set_name ${aws_assume_role}
	fi
}

aws_assume_role_is_tmp_credential_valid() {
	if [[ "true" = "$(aws_assume_role_unzip_tmp_credential_valid ${ASSUME_ROLE})" ]]; then
		echo -ne "\e]1;AWS-PROFILE[ ${ASSUME_ROLE} ]\a"
		aws_assume_role_re_use_current
	fi

}

aws_call_assume_role() {
	# Do later (Validate the variable of ASSUMED_ROLE before calling assume role)
	unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_SECURITY_TOKEN ASSUMED_ROLE AWS_ACCOUNT_ID
	tmp_credentials_file="${tmp_credentials}/${ASSUME_ROLE}"
	tmp_credentials_file_zip="${tmp_credentials}/${ASSUME_ROLE}.zip"

	assume_role_duration="$((${aws_assume_role_expired_time} - 5))"
	if [[ -f ${tmp_credentials_file_zip} ]]; then
		if [[ "$(aws_assume_role_unzip_tmp_credential_valid ${ASSUME_ROLE})" = "true" ]]; then
			echo "Re-use the temporary credential of ${ASSUME_ROLE} at ${tmp_credentials_file_zip}"
		else
			echo "The credential is older than ${aws_assume_role_expired_time} or the credential is empty then we will run assume-role ${ASSUME_ROLE} again"
			aws_assume_role_get_credential
		fi
	else
		aws_assume_role_get_credential
	fi
	import_tmp_credential

}

aws_assume_role_set_name() {

	function aws_assume_role_save_current_assume_role() {
		echo "${ASSUME_ROLE}" >${1:?'aws_cli_current_assume_role_name is unset or empty'}
	}

	aws_assume_role_name=$1
	echo You set the assume role name ${aws_assume_role_name:?"The assume role name is unset or empty"}

	export ASSUME_ROLE=${aws_assume_role_name}
	export assume_role=${aws_assume_role_name}
	# export ASSUMED_ROLE=${aws_assume_role_name}
	aws_call_assume_role

	tmp_credentials_file_zip="${tmp_credentials}/${ASSUME_ROLE}.zip"
	if [[ -f $tmp_credentials_file_zip ]]; then
		# cd ${aws_cli_results}

		if [[ "${aws_assume_role_print_account_info}" = "true" ]]; then
			aws_account_info
		fi
	else
		echo "Please try again, the assume role action was not complete"
	fi

	echo -ne "\e]1;AWS-PROFILE[ ${ASSUME_ROLE} ]\a"
	echo "You are using the assume role name ${ASSUME_ROLE}"

	aws_assume_role_save_current_assume_role ${aws_cli_current_assume_role_name}
}

function peco_aws_asssume_role_list() {
	# To ignore comment profile
	cat ~/.aws/config | grep -E '^\[profile (.*)\]$' | sed -E 's|^\[profile (.*)\]$|\1|g'

}

function aws_assume_role_set_name_with_hint() {

	function aws_assume_role_insert_current_asssume_role_first() {
		assume_role_list=$1
		if [[ -n "${ASSUME_ROLE}" ]]; then
			assume_role_list=$(echo ${assume_role_list} | grep -v -E "${ASSUME_ROLE}$")
			assume_role_list=$(echo "${ASSUME_ROLE}\n${assume_role_list}")

		fi

		echo ${assume_role_list}
	}

	local assume_role_list=$(aws_assume_role_insert_current_asssume_role_first "$(peco_aws_asssume_role_list)")
	local assume_role_name=$(peco_create_menu 'echo ${assume_role_list}' '--prompt "Please select your assume role name >"')
	aws_assume_role_set_name $assume_role_name

}

aws_assume_role_get_aws_account_id() {
	local aws_account_id=$(aws_run_commandline_with_retry 'aws sts get-caller-identity --query "Account" --output text' "true")
	export AWS_ACCOUNT_ID=$aws_account_id

}

aws_account_info() {
	echo "Alias $(get-account-alias)"
	aws_assume_role_get_aws_account_id
	echo "AccountId ${AWS_ACCOUNT_ID}"
	echo AWS Region ${AWS_REGION:?"The AWS_REGION is unset or empty"}
}

aws_assume_role_get_tmp_credentials_for_new_members() {
	local tmp_credentials_file="${tmp_credentials}/${ASSUME_ROLE}"
	aws_assume_role_set_name_with_hint
	aws_assume_role_unzip_tmp_credential $assume_role
	cat ${tmp_credentials_file} && rm -rf ${tmp_credentials_file}

}

aws_assume_role_get_tmp_credentials_for_credential_setting_file() {
	local tmp_credentials_file="${tmp_credentials}/${ASSUME_ROLE}"
	aws_assume_role_set_name_with_hint

	local lhs_docs=$(
		cat <<-__EOF__
			[${ASSUME_ROLE}-temp]
				aws_access_key_id = ${AWS_ACCESS_KEY_ID}
				aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
				aws_session_token = ${AWS_SESSION_TOKEN}
				region = ${AWS_REGION}

		__EOF__
	)

	echo "$lhs_docs"

	echo "$lhs_docs" >>${HOME}/.aws/credentials
	echo "Add to the file ${HOME}/.aws/credentials"

}

function aws_assume_role_get_tmp_credentials_for_env_docker_compose_setting_file() {
	aws_assume_role_set_name_with_hint
	local lhs_docs=$(
		cat <<-__EOF__
			AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
			AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
			AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}
			AWS_REGION=${AWS_REGION}
		__EOF__
	)

	echo "$lhs_docs"
}
