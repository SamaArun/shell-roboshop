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
if [ $USERID -ne 0 ]; 
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

echo "Please enter rabbitmq password to setup"
read -s RABBITMQ_PASSWORD

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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enaling rabbitmq server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting rabbitmq server"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWORD &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script execution compepleted successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE

#roboshop123