#!/bin/bash
aws_help() {
	local aws_assume_role_main_function="aws_assume_role_set_name_with_hint"
	local function_list=$(
		cat ${AWS_CLI_SOURCE_SCRIPTS}/{services,common}/* |
			grep -e "^aws*\(.+*\)" | tr -d "(){" |
			grep -v ${aws_assume_role_main_function} |
			sort
	)

	local BUFFER=$(
		echo "${aws_assume_role_main_function}\n${function_list}" | peco --query "$LBUFFER"
	)
	CURSOR=$#BUFFER
}

aws_main_function() {
	local aws_assume_role_main_function="aws_assume_role_set_name_with_hint"
	local BUFFER=$(
		echo "${aws_assume_role_main_function}" | peco --query "$LBUFFER" --select-1
	)
	CURSOR=$#BUFFER

}

# aws_run() {
# 	aws_custom_commandline=$(cat ${AWS_CLI_SOURCE_SCRIPTS}/services/* | grep -e "^aws*\(.+*\)" | grep "with_hint" | tr -d "(){" | sort | peco)
# 	echo Running the commandline ${aws_custom_commandline:?"The commandline is unset or empty. Then do nothing"}
# 	eval $aws_custom_commandline
# }

aws_get_command() {
  if [ ! -s ${aws_cli_input_folder}/aws_list_services.txt ]; then
    curl -s https://awscli.amazonaws.com/v2/documentation/api/latest/reference/index.html  | grep '<li class="toctree-l1"><a class="reference internal"' | awk -F '.html">' '{print $2}' | awk -F '</a>' '{print $1}' > ${aws_cli_input_folder}/aws_list_services.txt
  fi

  local aws_service=$(cat ${aws_cli_input_folder}/aws_list_services.txt | peco --prompt "Select service >")

  if [ -z $aws_service ]; then
      return
    fi

  if [ ! -s ${aws_cli_list_commands_folder}/aws_service.txt ]; then
      curl -s https://awscli.amazonaws.com/v2/documentation/api/latest/reference/$aws_service/index.html  | grep '<li class="toctree-l1"><a class="reference internal"' | awk -F '.html">' '{print $2}' | awk -F '</a>' '{print $1}' > ${aws_cli_list_commands_folder}/$aws_service.txt
    fi

  local aws_command=$(cat ${aws_cli_list_commands_folder}/$aws_service.txt | peco --prompt "aws $aws_service" --on-cancel error)

  if [ -z $aws_command ]; then
        return
    fi

  local final_action=$(echo -e "input\ndocument\nhelp" | peco)

  if [ $final_action = "document" ]; then
      open https://awscli.amazonaws.com/v2/documentation/api/latest/reference/$aws_service/$aws_command.html
      return
    elif [ $final_action = "help" ]; then
      "aws $aws_service $aws_command help"
      return
    fi

  echo
  local GREEN='\033[0;32m'
  local NC='\033[0m'
  echo -e "${GREEN}aws $aws_service $aws_command${NC}"
  local BUFFER=$(
  		echo "aws $aws_service $aws_command" | peco --query "$LBUFFER" --select-1
  	)
  	CURSOR=$#BUFFER
}