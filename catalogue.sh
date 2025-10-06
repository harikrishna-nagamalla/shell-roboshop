#!/bin/bash         

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
MONGODB_HOST=mongodb.nagamalla.fun
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

### NodeJS ###
dnf module disable nodejs -y &>>$LOG_FILE
Validate $? "Disabling NodeJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
Validate $? "Enabling NodeJS"

dnf install nodejs -y &>>$LOG_FILE
Validate $? "Installing NodeJS"

### Creating System User ###
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
Validate $? "Creating system user"

### Creating App Directory ###
mkdir /app
Validate $? "Creating app directory"

### Downloading Catalogue Application ###
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
Validate $? "Downloading Catalogue Application"

### Unzipping Catalogue Application ###
cd /app
Validate $? "Changing to app directory"
unzip /tmp/catalogue.zip &>>$LOG_FILE
Validate $? "Unzipping Catalogue Application"

### Installing Dependencies ###
npm install &>>$LOG_FILE
Validate $? "Installing dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
Validatie $? "Copy systemctl service"

systemctl enable catalogue &>>$LOG_FILE
Validate $? "Enable systemctl service"

systemctl daemon-reload
Validate $? "Reload systemctl service"

cp mongo.repo /etc/yum.repos.d/mongo.repo
Validate $? "Copy mongo repo"

systemctl start catalogue
Validate $? "Start catalogue"


dnf install mongodb-mongosh -y &>>$LOG_FILE
Validate $? "Installing mongo client"

mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
Validate $? "Loading catalogue products"

systemctl restart catalogue
Validate $? "Restarting catalogue"