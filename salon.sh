#!/bin/bash


PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #services menu
  SERVICES=$($PSQL "Select * from services")
  echo "$SERVICES" | while read ID NAME
  do
    echo $ID $NAME | sed 's/|/) /g'
  done

  #service id select
  read SERVICE_ID_SELECTED
  #if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #go to main menu
    MAIN_MENU "Please input a number."
  else
    SERVICE_SELECTED=$($PSQL "select * from services where service_id = $SERVICE_ID_SELECTED")
    #if invalid, go main menu
    if [[ -z $SERVICE_SELECTED ]]
    then
      MAIN_MENU "Invalid service selected, please select from the list."
    else
    #else go to customer menu
    APPOINTMENT_MENU
    fi
  fi
}


APPOINTMENT_MENU() {
  #ask phone number
  echo -e "\nPhone number, please."
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

  #if not in database
  if [[ -z $CUSTOMER_NAME ]]
  then
    #ask for name
    echo -e "\nName, please."
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  #get customer id
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    
  #ask time
  echo -e "\nWhat time?"
  read SERVICE_TIME
  #add time to appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")


  #print appointment message
  SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

}





MAIN_MENU "Welcome to my nail salon! How may I help you?"