#!/usr/bin/python

import boto

conn = boto.connect_s3('AKIAJSQQ2KJ6E7TUOYQA','mKjHnn82CUU5m/7Ei20KfCKwrb8EJXYFN2JW5Q77')

bucket = conn.create_bucket('mykammu1')
