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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOG
VALIDATE $? "Configure YUM Repo"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOG
VALIDATE $? "Configure YUM Repo"

dnf install rabbitmq-server -y  &>> $LOG
VALIDATE $? "Installing RabbitMQ Server"

systemctl enable rabbitmq-server &>> $LOG
VALIDATE $? "Enabling RabbitMQ Server"

systemctl start rabbitmq-server &>> $LOG
VALIDATE $? "Starting RabbitMQ Server"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG
VALIDATE $? "Adding User & Password"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG
VALIDATE $? "Giving permissions to user"