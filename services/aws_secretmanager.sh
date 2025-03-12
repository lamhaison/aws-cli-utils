#!/bin/bash

###################################################################
# # @script			aws_secret_manager.sh
# # @author		 	lamhaison
# # @email		 	lamhaison@gmail.com
###################################################################

function aws_secretmanager_list() {
	aws_run_commandline "\
		aws secretsmanager list-secrets \
		--query '*[].{Name:Name,Description:Description}' \
		--output table
	"
}

function aws_secretmanager_get() {
	local secret_name=$1

	# Check input invalid
	if [[ -z "$secret_name" ]]; then return; fi
	aws_run_commandline "\
		aws secretsmanager describe-secret --secret-id '${secret_name}'
	"
}

function aws_secretmanager_get_with_hint() {
	local secret_name=$(peco_create_menu 'peco_aws_secretmanager_list' '--prompt "Choose secret that you want >"')

	# Check input invalid
	if [[ -z "$secret_name" ]]; then return; fi
	aws_secretmanager_get "${secret_name}"
}

function aws_secretmanager_get_value() {
	local secret_name=$1
	local nolog=${2:-'no'}
	# Check input invalid
	if [[ -z "$secret_name" ]]; then return; fi

	if [[ "$nolog" = "yes" ]]; then
		aws secretsmanager get-secret-value \
			--secret-id "${secret_name}"
	else

		aws_run_commandline "\
		aws secretsmanager get-secret-value \
			--secret-id "${secret_name}"
	"

	fi

}

function aws_secretmanager_get_value_with_hint() {
	local secret_name=$(peco_create_menu 'peco_aws_secretmanager_list' '--prompt "Choose secret that you want >"')
	aws_secretmanager_get_value "${secret_name}"
}

function aws_secretmanager_get_value_with_specific_key_with_hint() {
	local secret_name=$(peco_create_menu 'peco_aws_secretmanager_list' '--prompt "Choose secret that you want >"')
	aws_secretmanager_get_value_with_specific_key "${secret_name}" ""

}

function aws_secretmanager_list_keys() {
	local secret_name="$1"

	# Validate input
	if [[ -z "$secret_name" ]]; then
		echo "Usage: aws_secretmanager_list_keys <secret-name>"
		return 1
	fi

	# Fetch the secret value
	local secret_json
	secret_json=$(aws secretsmanager get-secret-value --secret-id "$secret_name" --query SecretString --output text 2>/dev/null)

	# Check if secret retrieval was successful
	if [[ -z "$secret_json" ]]; then
		echo "Failed to retrieve secret or secret is empty."
		return 1
	fi

	# List all keys using jq
	echo "$secret_json" | jq -r 'keys[]'
}

function aws_secretmanager_list_keys_with_hint() {
	local secret_name=$(peco_create_menu 'peco_aws_secretmanager_list' '--prompt "Choose secret that you want >"')

	echo "Keys in secret '$secret_name':"
	aws_secretmanager_list_keys "${secret_name}"
}

function aws_secretmanager_get_value_with_specific_key() {

	local secret_name=$1
	# No log to file
	secret_string=$(aws_secretmanager_get_value "${secret_name}" "yes" | jq '.SecretString')
	secret_string_json=$(python3 -c "import sys,json; print(json.loads(sys.argv[1]))" "${secret_string}" | jq)
	local secret_keys=$(echo "${secret_string_json}" | jq -r 'keys_unsorted[]')

	local secret_key=$(peco_create_menu 'echo ${secret_keys}' '--prompt "Choose secret key that you want get value>"')

	# Check input invalid
	if [[ -z "$secret_key" ]]; then
		echo "The secret key is invalid"
		return
	fi

	local secret_value=$(echo "${secret_string_json}" | jq -r ".${secret_key}")
	echo "${secret_key}=${secret_value}"

}

function aws_secretmanager_update_secret() {
	local secret_name="$1"
	local secret_key="$2"
	local secret_value="$3"
	local existing_secret_json
	local updated_secret_json

	# Check input invalid
	if [[ -z "$secret_name" ]]; then return; fi
	if [[ -z "$secret_key" ]]; then return; fi
	if [[ -z "$secret_value" ]]; then return; fi

	# Fetch the existing secret value
	existing_secret_json=$(aws secretsmanager get-secret-value --secret-id "$secret_name" --query SecretString --output text 2>/dev/null || echo "")

	# Check if the secret exists
	if [[ "$existing_secret_json" == "" ]]; then
		echo "Secret '$secret_name' not found or has no existing JSON data. Creating a new secret."

		# shellcheck disable=SC2155
		local updated_secret_json=$(
			cat <<-__EOF__
				{
					"${secret_name}": "${secret_value}"
				}
			__EOF__
		)

		echo "$lhs_docs"
	else
		# Update the JSON secret by modifying the key-value pair
		echo "\nAppend to the exsting json"
		updated_secret_json=$(echo "$existing_secret_json" | jq --arg key "$secret_key" --arg value "$secret_value" '.[$key] = $value')
	fi

	# Update the secret in AWS Secrets Manager
	aws secretsmanager put-secret-value --secret-id "$secret_name" --secret-string "$updated_secret_json"

	echo "Secret '$secret_name' updated with key ${secret_key} successfully."
}

function aws_secretmanager_update_specific_secret_key_with_hint() {

	local secret_name=$(peco_create_menu 'peco_aws_secretmanager_list' '--prompt "Choose secret that you want >"')

	# Check input invalid
	if [[ -z "$secret_name" ]]; then
		echo "Secret name is invalid. "
		return
	fi

	echo "List existing keys"
	aws_secretmanager_list_keys "${secret_name}"

	while true; do
		echo -n "Enter name of secret key (or press Enter to finish): "
		read secret_key

		# Break loop if user presses Enter without input
		if [[ -z "$secret_key" ]]; then
			break
		fi

		echo -n "Enter value for '${secret_key}': "
		read -s secret_value
		echo

		# Validate secret value
		if [[ -z "$secret_value" ]]; then
			echo "Secret value cannot be empty."
			continue
		fi

		aws_secretmanager_update_secret "${secret_name}" "${secret_key}" "${secret_value}"

	done

}

function aws_secretmanager_delete_key() { # Be careful when using this
	local secret_name="$1"
	local key_to_delete="$2"

	# Validate inputs
	if [[ -z "$secret_name" || -z "$key_to_delete" ]]; then
		echo "Usage: aws_secretmanager_delete_key <secret-name> <key-to-delete>"
		return 1
	fi

	# Fetch the existing secret value
	local existing_secret_json
	existing_secret_json=$(aws secretsmanager get-secret-value --secret-id "$secret_name" --query SecretString --output text 2>/dev/null)

	# Validate secret retrieval
	if [[ -z "$existing_secret_json" ]]; then
		echo "Secret '$secret_name' not found or has no existing data."
		return 1
	fi

	# Check if key exists
	if ! echo "$existing_secret_json" | jq -e --arg key "$key_to_delete" 'has($key)' >/dev/null; then
		echo "Key '$key_to_delete' not found in secret '$secret_name'."
		return 1
	fi

	# Remove the key from the JSON
	local updated_secret_json
	updated_secret_json=$(echo "$existing_secret_json" | jq "del(.\"$key_to_delete\")")

	# Update the secret in AWS Secrets Manager
	aws secretsmanager put-secret-value --secret-id "$secret_name" --secret-string "$updated_secret_json"

	echo "Key '$key_to_delete' has been removed from secret '$secret_name'."
}

function aws_secretmanager_delete_key_with_hint() { # # Be careful when using this
	local secret_name=$(peco_create_menu 'peco_aws_secretmanager_list' '--prompt "Choose secret that you want >"')

	# Check input invalid
	if [[ -z "$secret_name" ]]; then return; fi

	local secret_key=$(peco_create_menu 'aws_secretmanager_list_keys ${secret_name}' '--prompt "Choose secret key that you want >"')

	aws_secretmanager_delete_key "${secret_name}" ${secret_key}

}
