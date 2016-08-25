#!/usr/bin/python

import boto

conn = boto.connect_s3()

bucket = conn.create_bucket('kammu')
