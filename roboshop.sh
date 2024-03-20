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
DOMAIN_NAME=learndevops.space
ZONE_ID=Z02357183AC34D1F7B6MH
for i in "${INSTANCES[@]}"
do
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t2.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    PRIVATE_IP=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo "$i : $PRIVATE_IP"

#Create Route 53 Records, make sure you delete the existing records.
aws route53 change-resource-record-sets \
--hosted-zone-id $ZONE_ID \
--change-batch '
{
    "Comment": "Creating Route 53 records"
    ,"Changes": [{
    "Action"              : "UPSERT"
    ,"ResourceRecordSet"  : {
        "Name"              : "'$i'.'$DOMAIN_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$PRIVATE_IP'"
        }]
    }
    }]
}
    '    
done