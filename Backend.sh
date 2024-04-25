#!/bin/bash

user=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
scriptname=$( echo $0 | cut -d "." -f1)
logfile=/tmp/$scriptname-$timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Pls enter DB pswwd"
read -s mysql_root_password

validate(){
    if [ $1 -eq 0 ]
    then 
        echo -e "$2...$G Success $N"
    else
        echo -e "$2...$R Failure $N"
    fi 
}

if [ $user -eq 0 ]
then    
    echo -e "user is having $G root access $N" 
else
    echo -e " $R Run with root access $N"
    exit 1
fi


dnf module disable nodejs -y &>>$logfile
validate $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$logfile
validate $? "Enabling nodejs:20"

dnf install nodejs -y &>>$logfile
validate $? "Installing nodejs"

# useradd expense &>>logfile
# validate $? "User is added"

#the above is not correct since once the user is created for next time run it will fail. hence we need to do idemptency

#id is command to find the user is present or not

id expense
if [ $? -eq 0 ]
then 
    echo -e "User is created...$Y Skipping $N"
else
    useradd expense
    validate $? "craeting user expense"
fi

# mkdir /app
# validate $? "Craeting the folder"
# The above will fail after first run because it is idempotent to overcome we just need to keep -p before mkdir so after success 
# if we run again to will skip and doen't throw error 

mkdir -p /app &>>$logfile
validate $? "Craeting the folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>logfile
validate $? "Downloading code from backend"


cd /app 
rm -rf /app/* 
unzip /tmp/backend.zip &>>$logfile
validate $? "Unziping the backend code"

npm install &>>$logfile
validate $? "Installing the dependencies"

cp /home/ec2-user/Expense-Shell/Backend.Service /etc/systemd/system/backend.service &>>$logfile
validate $? "Copied backend.service"

systemctl daemon-reload &>>$logfile
validate $? "Reloading the backend"

systemctl start backend &>>$logfile
validate $? "Starting backend"

systemctl enable backend &>>$logfile
validate $? "Enabling the backend"


dnf install mysql -y &>>$logfile
validate $? "Installing mysql"

mysql -h db.bhavya.store -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$logfile
validate $? "Schema loading"

systemctl restart backend &>>$logfile
validate $? "Restarting backend"


