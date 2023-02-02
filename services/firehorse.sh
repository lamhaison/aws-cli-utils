#!/bin/bash

aws_firehorse_list() {
	aws_run_commandline "\
		aws firehose list-delivery-streams
	"
}

aws_firehorse_get() {
	aws_firehorse_delivery_stream_name=$1
	aws_run_commandline "\
		aws firehose describe-delivery-stream \
			--delivery-stream-name ${aws_firehorse_delivery_stream_name:?'aws_firehorse_delivery_stream_name is unset or empty'}
	"
}
