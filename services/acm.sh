#!/bin/bash
# AWS acm

aws_acm_list() {
	for item in $(aws acm list-certificates --query "*[].CertificateArn" --output text)
	do 
		aws acm describe-certificate --certificate-arn $item --query "*[].{CertificateArn:CertificateArn,DomainName:DomainName,SubjectAlternativeNames:SubjectAlternativeNames,Type:Type}"
	done
}