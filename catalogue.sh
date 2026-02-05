#!/bin/bash

# USERID=$(id -u)
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"
# LOGS_FLODER="/var/log/roboshop-logs"
# SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
# LOG_FILE="$LOGS_FLODER/$SCRIPT_NAME.log"
# SCRIPT_DIR=$PWD

# mkdir -p $LOGS_FLODER
# echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# #check the user has root access or not
# if [ $USERID -ne 0 ]; 
# then
#     echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE

#     exit 1
# else
#     echo "You are running with root access" | tee -a $LOG_FILE

# fi
# # validate function takes input as exit status, what commad they tried to install
# VALIDATE(){
#     if [ $1 -eq 0 ]; 
#     then
#         echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE

#     else
#         echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE

#         exit 1
#     fi
# }

source ./common.sh
app_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup

# dnf module disable nodejs -y &>>$LOG_FILE
# VALIDATE $? "Disabling default nodejs"

# dnf module enable nodejs:20 -y &>>$LOG_FILE
# VALIDATE $? "Enabling nodejs:20"

# dnf install nodejs -y &>>$LOG_FILE
# VALIDATE $? "Installing nodejs:20"

# id roboshop
# if [ $? -ne 0 ]
# then
# useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
# VALIDATE $? "Creating roboshop system user"
# else
#     echo -e "System user roboshop already cretaed .. $Y SKIPPING $N"
# fi

# mkdir -p /app #-p if not created it create other wise it will not
# VALIDATE $? "Creating app directory"

# curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
# VALIDATE $? "Downloading catalogue"

# rm-rf /app/*
# cd /app 
# unzip /tmp/catalogue.zip &>>$LOG_FILE
# VALIDATE $? "unzipping catalogue"

# npm install &>>$LOG_FILE
# VALIDATE $? "Installing Dependencies"

# cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
# VALIDATE $? "Copying catalogue service"

# systemctl daemon-reload &>>$LOG_FILE
# systemctl enable catalogue  &>>$LOG_FILE
# systemctl start catalogue
# VALIDATE $? "Starting Catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing MngoDB Client"

STATUS=$(mongosh --host MONGODB-SERVER-IPADDRESS --eval 'db.getMongo().getDBNames().indexof("Catalogue")') #to check if db is already there, if output(-1), them db is not there
if [ $STATUS -lt 0 ]
then
    mongosh --host MONGODB-SERVER-IPADDRESS </app/db/master-data.js &>>$LOG_FILE #change the IP ADDRESS
    VALIDATE $?  "LOADING DATA into MongoDB"
else
    echo -e "Data is already loaded.. $Y SKIPPING $N"
fi



print_time



#less /var/log/roboshop-logs/catalogue.log (for logs)