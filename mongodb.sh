#!/bin/bash         

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" 

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR :: Run this script with root previleges"
    exit 1
fi

Validate() {

    if [ $1 -ne 0 ]; then
        echo -e "$2 is... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 is... $G SUCCESS $N"
    fi
    
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
Validate $? "AddingMongo Repo"

dnf install mongodb-org -y &>>$LOG_FILE
Validate $? "Installing MongoDB"

systemctl enable mongod 
Validate $? "Enable MongoDB"

systemctl start mongod
Validate $? "Start MongoDB"