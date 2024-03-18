#!/bin/bash

# Algorithm
# 
#
#
#
#
#
#
#
#

AMI=ami-0f3c7d07486cad139
SG_ID=sg-04d3cc3675c0c646f
INSTANCES=("mongodb" "redis" "mysql" "catalogue" "user" "cart" "shipping" "payment" "rabbitmq" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
    echo "Instance is $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t2.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance, Tags=[{key=Name,Value=$i}]"

done