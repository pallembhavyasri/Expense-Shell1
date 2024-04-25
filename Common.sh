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


current_root(){
    if [ $user -eq 0 ] 
    then    
        echo -e "user is having $G root access $N" 
    else
        echo -e " $R Run with root access $N"
        exit 1
fi
}