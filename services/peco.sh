# brew install peco
# PECO
peco_assume_role_name() {
	cat ~/.aws/config |grep -e "^\[profile.*\]$" | peco
}


peco_aws_acm_list() {
	aws_acm_list | peco
}	

peco_aws_logs_list() {
	aws_logs_list | peco
}