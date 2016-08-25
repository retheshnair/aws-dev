#!/usr/bin/python

import boto

conn = boto.connect_s3('aws_access_key_id','aws_secret_access_key')

bucket = conn.create_bucket('newbucketname')
