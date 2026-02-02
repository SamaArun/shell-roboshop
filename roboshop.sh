#!/bin/bash

AMI_ID="ami-0532be01f26a3de55"
SG_ID="sg-03d101dcaa6a55f3d"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
# ZONE_ID="dsjnjsndnd"
# DOMAIN_NAME="arun.in"

#for instance in $@
for instance in "${INSTANCES[@]}"
do
    echo "Launching instance: $instance"

    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query "Instances[0].InstanceId" \
        --output text)

    echo "Waiting for instance $INSTANCE_ID to be running..."
    aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

    if [ "$instance" != "frontend" ];
    then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PrivateIpAddress" \
            --output text)
        #RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTANCE_ID" \
            --query "Reservations[0].Instances[0].PublicIpAddress" \
            --output text)
        #RECORD_NAME="$DOMAIN_NAME"
    fi

    echo "$instance IP address: $IP"

    # aws route53 change-resource-record-sets \
    # --hosted-zone-id $ZONE_ID \
    # --change-batch '
    #  {
    #     "Comment": "Creating or Updating a record set for cognito endpoint",
    #     "Changes": [{
    #         "Action": "UPSERT",
    #         "ResourceRecordSet": {
    #             "Name": "'$RECORD_NAME'",
    #             "Type": "A",
    #             "TTL": 1,
    #             "ResourceRecords": [{
    #                 "Value": "'$IP'"
    #             }]
    #         }
    #     }]
    #  }'
done







