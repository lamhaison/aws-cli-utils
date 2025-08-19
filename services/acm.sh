#!/bin/bash
# AWS acm

aws_acm_list() {
    for item in $(aws acm list-certificates --query "*[].CertificateArn" --output text); do
        aws_run_commandline \
            "
        aws acm describe-certificate \
            --certificate-arn $item \
            --query \"*[].{CertificateArn:CertificateArn,DomainName:DomainName,SubjectAlternativeNames:SubjectAlternativeNames,Type:Type}\"
        "
    done
}

aws_acm_import() {
    local certificate_arn="$1"
    local certificate_file="$2"
    local private_key_file="$3"
    local certificate_chain_file="$4"

    if [[ -z "$certificate_arn" || -z "$certificate_file" || -z "$private_key_file" || -z "$certificate_chain_file" ]]; then
        echo "Error: Missing required arguments."
        echo "Usage: aws_acm_import <certificate_arn> <certificate_file> <private_key_file> <certificate_chain_file>"
        return 1
    fi

    aws_run_commandline \
        "aws acm import-certificate \
        --certificate-arn $certificate_arn \
        --certificate fileb://$certificate_file \
        --private-key fileb://$private_key_file \
        --certificate-chain fileb://$certificate_chain_file"
}

aws_acm_delete() {
    local certificate_arn="$1"

    if [[ -z "$certificate_arn" ]]; then
        echo "Error: Missing required argument."
        echo "Usage: aws_acm_delete <certificate_arn>"
        return 1
    fi

    aws_run_commandline "aws acm delete-certificate --certificate-arn $certificate_arn"
}

aws_acm_request() {
    local domain_name="$1"
    local validation_method="$2"
    local subject_alternative_names="$3"

    if [[ -z "$domain_name" || -z "$validation_method" ]]; then
        echo "Error: Missing required arguments."
        echo "Usage: aws_acm_request <domain_name> <validation_method> [subject_alternative_names]"
        return 1
    fi

    local command="aws acm request-certificate --domain-name $domain_name --validation-method $validation_method"
    
    if [[ -n "$subject_alternative_names" ]]; then
        command="$command --subject-alternative-names $subject_alternative_names"
    fi

    aws_run_commandline "$command"
}

aws_acm_validate() {
    local certificate_arn="$1"
    local validation_record="$2"

    if [[ -z "$certificate_arn" || -z "$validation_record" ]]; then
        echo "Error: Missing required arguments."
        echo "Usage: aws_acm_validate <certificate_arn> <validation_record>"
        return 1
    fi

    aws_run_commandline \
        "aws acm validate-certificate \
        --certificate-arn $certificate_arn \
        --validation-record $validation_record"
}

aws_acm_get_validation_records() {
    local certificate_arn="$1"

    if [[ -z "$certificate_arn" ]]; then
        echo "Error: Missing required argument."
        echo "Usage: aws_acm_get_validation_records <certificate_arn>"
        return 1
    fi

    aws_run_commandline \
        "aws acm describe-certificate \
        --certificate-arn $certificate_arn \
        --query 'Certificate.DomainValidationOptions[].ResourceRecord'"
}

aws_acm_get_with_hint() {
    local certificate_list=$(aws acm list-certificates --query "*[].{Arn:CertificateArn,Domain:DomainName}" --output text | awk '{print $1 " (" $2 ")"}')
    local selected_certificate=$(peco_create_menu 'echo ${certificate_list}' '--prompt "Select ACM certificate >"' | awk '{print $1}')
    
    if [[ -n "$selected_certificate" ]]; then
        aws_run_commandline \
            "aws acm describe-certificate \
            --certificate-arn $selected_certificate \
            --query \"*[].{CertificateArn:CertificateArn,DomainName:DomainName,SubjectAlternativeNames:SubjectAlternativeNames,Type:Type}\""
    fi
}
