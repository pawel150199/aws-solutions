# Download SIX dataset

Some time ago I was struggling with idea of implementing server less workflow to download SIX data in rrd format once per week and save it into S3 bucket.

I have implemented my idea using Lambda function which is written in golang.

This workflow is triggered once per week using AWS Amazon Event Bridge.
