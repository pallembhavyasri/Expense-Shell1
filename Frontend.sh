#!/bin/bash

source ./Common.sh 

current_root

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

cp /home/ec2-user/Expense-Shell1/Frontend.Service /etc/nginx/default.d/expense.conf &>>$logfile
validate $? "copied the frontend service"

systemctl restart nginx &>>$logfile
validate $? "Restartting Nginx"




