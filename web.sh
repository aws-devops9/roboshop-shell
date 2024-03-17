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

dnf install nginx -y &>> $LOG
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOG
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>> $LOG
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG
VALIDATE $? "Removing default Nginx html"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOG
VALIDATE $? "Copying web.zip"

cd /usr/share/nginx/html &>> $LOG
VALIDATE $? "Go to html location"

unzip -o /tmp/web.zip &>> $LOG
VALIDATE $? "Unzipping web.zip"
 
cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOG
VALIDATE $? "Copying roboshop configuration file"

systemctl restart nginx &>> $LOG
VALIDATE $? "Restarting nginx"

