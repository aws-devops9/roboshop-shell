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
    else
        echo -e "$2....is $G SUCCESS.$N"
    fi
}

cp mongo.repo /etc/yu.repos.d/mongo.repo  &>> $LOG # Here we are tring to copy the repo to /etc/yum.repos.d/ folder
VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org -y  &>> $LOG
VALIDATE $? "Installing mongodb"

systemctl enable mongod &>> $LOG
VALIDATE $? "Enabling mongodb"

systemctl start mongod &>> $LOG
VALIDATE $? "Starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG
VALIDATE $? "Enabling Remote Access to MongoDb"
 
systemctl restart mongod &>> $LOG
VALIDATE $? "Restarting mongodb"