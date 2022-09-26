
#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

#-------------------------------------MESSAGES---------------------------------------
WELCOME_MSG="Welcome to My Salon, how can I help you?"
ASKING_PHONE_MSG="What's your phone number?"
ASKING_NAME_MSG="I don't have a record for that phone number, what's your name?"
ASKING_TIME_MSG="What time would you like your cut"

WRONG_SERVICE_ERR_MSG="I could not find that service. What would you like today?"
SERVICE_VALIDATION_ERR_MSG="Please pick a valid option (using numbers)"


#------------------------------- SERVICE PICKING MENU-------------------------------
MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id");
  echo -e "\n$WELCOME_MSG\n"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED

#-------------------------------SERVICE_ID_SELECTED VALIDATION---------------------------
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]$ ]]
  then 
    MENU "$SERVICE_VALIDATION_ERR_MSG"
  else
    CHECK_IF_SERVICE_EXISTS=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $CHECK_IF_SERVICE_EXISTS ]]
    then
      MENU "$WRONG_SERVICE_ERR_MSG"
    else
      CUSTOMER_MENU
    fi
  fi
}


#----------------------------------GETTING CLIENT INFO------------------------------
CUSTOMER_MENU() {
  echo -e "\n$ASKING_PHONE_MSG"
  read CUSTOMER_PHONE
#-------------------------------CHECKING IF CLIENT EXISTS---------------------------
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
#----------------------------------INSERTING NEW CLIENT------------------------------
    echo -e "\n$ASKING_NAME_MSG"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi
#--------------------------GETTING CLIENT ID & GOING TO APPOINTMENTS------------------
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  APPOINTMENT_MENU  
}


#-------------------------------GETTING APPOINTMENT INFO--------------------------------
APPOINTMENT_MENU(){
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  echo -e "\n$ASKING_TIME_MSG,$CUSTOMER_NAME?"
  read SERVICE_TIME
#---------------------------------INSERTING APPOINTMENT---------------------------------
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  SERVICE_NAME=$($PSQL "SELECT name FROM services FULL JOIN appointments USING(service_id) WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
}


MENU
