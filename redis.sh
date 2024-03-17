#!?bin/bash

ID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOG="/tmp/$0-$TIMESTAMP.log"
PACKAGE="mongodb"

R="\e[31m" # Red Colour
G="\e[32m" # Green colour
Y="\e[33m" # Yellow colour
N="\e[0m" # No colour

echo -e "Script started executing : $G..$TIMESTAMP $N" 

if [ $ID != 0 ]
then
    echo "ERROR: You do not have root permission to run this command"
    exit 1
else
    echo "You are a Root user, proceed."
fi

VALIDATE(){
    if [ $? != 0 ]
    then
        echo -e "$2....is $R FAILED.$N"
        exit 1
    else
        echo -e "$2....is $G SUCCESS.$N"
    fi
}

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOG
VALIDATE $? "Installing Remi repo 18"

dnf module enable redis:remi-6.2 -y &>> $LOG
VALIDATE $? "Enabling Redis-Remi 6.2" 

dnf install redis -y &>> $LOG
VALIDATE $? "Installing redis" 

sed - i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOG
VALIDATE $? "Enabling Remote Access to Redis"

systemctl enable redis &>> $LOG
VALIDATE $? "Enabling redis" 

systemctl start redis &>> $LOG
VALIDATE $? "Starting redis" 