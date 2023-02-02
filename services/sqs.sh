#!/bin/bash

aws_sqs_list() {
	aws_run_commandline "\
		aws sqs list-queues
	"
}
