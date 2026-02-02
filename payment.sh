#!/bin/bash

START_TIME=$(date +%s) #gives time in seconds
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FLODER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FLODER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FLODER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

#check the user has root access or not
if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1
else
    echo "You are running with root access" | tee -a $LOG_FILE

fi
# validate function takes input as exit status, what commad they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]; 
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE

    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Install python3 packages"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already cretaed .. $Y SKIPPING $N"
fi

mkdir -p /app #-p if not created it create other wise it will not
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading payment"

rm-rf /app/*
cd /app 
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzipping payment"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Coping payment service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon-Reload"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "Enable payment:"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "Starting payment"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script execution completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE





##UPDATE IPS IN SERVICE FILE