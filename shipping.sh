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

dnf install maven -y &>> $LOG
VALIDATE $? "Installing Maven" 

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOG
VALIDATE $? "Downloading Shipping Application" 

cd /app &>> $LOG
VALIDATE $? "Go to App Directory"

unzip -o /tmp/shipping.zip  &>> $LOG # -o is used for overwrite
VALIDATE $? "Unzipping shipping.zip" 

cd /app &>> $LOG
VALIDATE $? "Go to App Directory"

mvn clean package &>> $LOG
VALIDATE $? "Installing Dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOG
VALIDATE $? "renaming Shipping-1.0"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOG
VALIDATE $? "Copying shipping.service"

systemctl daemon-reload &>> $LOG
VALIDATE $? "Daemon reloading"

systemctl enable shipping  &>> $LOG
VALIDATE $? "enabling Shipping"

systemctl start shipping &>> $LOG
VALIDATE $? "Starting Shipping"

dnf install mysql -y &>> $LOG
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.learndevops.space -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOG
VALIDATE $? "Loading shipping application into mysql"

systemctl restart shipping &>> $LOG
VALIDATE $? "Restarting Shipping"