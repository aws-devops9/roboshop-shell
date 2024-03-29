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

dnf module disable nodejs -y &>> $LOG
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:18 -y &>> $LOG
VALIDATE $? "Enabling NodeJS"

dnf list installed nodejs &>> $LOG
if [ $? != 0 ]
then 
    dnf install nodejs -y &>> $LOG
VALIDATE $? "Installing NodeJS 18"
else
   echo -e "NodeJS is already Installed...$Y SKIPPING $N" 
fi      

id roboshop &>> $LOG
if [ $? != 0 ]
then 
    useradd roboshop &>> $LOG
    VALIDATE $? "Creating Roboshop User"
else
    echo -e "User ROBOSHOP is already exist...$Y SKIPPING $N" 
fi      

mkdir -p /app &>> $LOG # -p will create directory if it is not exist or it will skip If it's already exist
VALIDATE $? "Creating App Directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOG # -o is used for overwrite
VALIDATE $? "Downloading Cart Application"

cd /app &>> $LOG
VALIDATE $? "Goto App Directory"

unzip -o /tmp/cart.zip &>> $LOG # -o is used for overwrite
VALIDATE $? "Unzipping Cart.zip"

cd /app &>> $LOG
VALIDATE $? "Goto App Directory"

npm install &>> $LOG
VALIDATE $? "Installing dependencies"

#Use absolute path because catalogue.service exist there.
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOG
VALIDATE $? "Copying cart.service"

systemctl daemon-reload &>> $LOG
VALIDATE $? "Daemon Reload"

systemctl enable cart &>> $LOG
VALIDATE $? "Enabling cart"

systemctl start cart &>> $LOG
VALIDATE $? "Starting cart"