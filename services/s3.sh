#!/bin/bash

aws_s3_ls() {
	aws_s3_list
}
aws_s3_list() {
	aws_run_commandline "aws s3 ls"
}