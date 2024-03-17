#!?bin/bash

# Here "!= and "-ne" BOTH ARE SAME means not equal to"

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


dnf install python36 gcc python3-devel -y &>> $LOG
VALIDATE $? "Installing Python"

id roboshop &>> $LOG
if [ $? != 0 ]
then 
    useradd roboshop &>> $LOG
    VALIDATE $? "Creating Roboshop User"
else
    echo -e "User ROBOSHOP is already exist...$Y SKIPPING $N" 
fi 

mkdir -p /app &>> $LOG
VALIDATE $? "Creating App directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOG
VALIDATE $? "Downloading Payment Application"

cd /app
VALIDATE $? "Go To App Directory"  &>> $LOG

unzip /tmp/payment.zip &>> $LOG
VALIDATE $? "Unzipping payment.zip" 

cd /app &>> $LOG
VALIDATE $? "Go To App Directory" 

pip3.6 install -r requirements.txt &>> $LOG
VALIDATE $? "Install dependencies" 

cp /home/centos/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOG
VALIDATE $? "Copying payment.service" 

systemctl daemon-reload &>> $LOG
VALIDATE $? "Daemon Reload" 

systemctl enable payment  &>> $LOG
VALIDATE $? "Enabling Payment" 
 
systemctl start payment  &>> $LOG
VALIDATE $? "Starting Payment" 