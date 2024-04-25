#!/bin/bash

source ./Common.sh

current_root

echo "Pls enter DB pswwd"
read -s mysql_root_password

dnf install mysql-server -y &>>$logfile 
validate $? "Installing Mysql"

systemctl enable mysqld &>>$logfile
validate $? "Enabling mysql"

systemctl start mysqld &>>$logfile
validate $? "Starting Mysql"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#validate $? "setting up root password"

#idempotency means for every run it will not consider newly once it is success and then rerun again it takes as failure
#Since before is suucess and shells cript is not idempotent

mysql -h db.bhavya.store -u root -p${mysql_root_password} -e 'show databases;' &>>$logfile
if [ $? -eq 0 ]
then    
    echo -e "Already password setup is completed..$Y Skipping $N"
else
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$logfile
    validate $? "MYSQL Root pssword setup"
fi



