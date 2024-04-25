#!/bin/bash

user=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
scriptname=$( echo $0 | cut -d "." -f1)
logfile=/tmp/$scriptname-$timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install nginx -y &>>$logfile
validate $? "Installing Nginx"

systemctl enable nginx &>>$logfile
validate $? "Enabling Nginx"

systemctl start nginx &>>$logfile
validate $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$logfile
validate $? "delected all the content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
validate $? "Downloading the code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$logfile #here unzip is the idempotent because in the above step we are delecting everytime
validate $? "Unziping the file"

cp /home/ec2-user/Expense-Shell/Frontend.Service /etc/nginx/default.d/expense.conf &>>$logfile
validate $? "copied the frontend service"

systemctl restart nginx &>>$logfile
validate $? "Restartting Nginx"




