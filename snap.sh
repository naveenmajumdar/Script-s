#!/bin/bash
echo "creating snapshot"
aws ec2 create-snapshot --region us-west-1 --output=text --description $HOSTNAME $DATE  --volume-id <VOLUME-ID>
