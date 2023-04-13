#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?\n" # Display the services and ask for the service that the client wants to book

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME" 
  done
  
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) SERVICE ;;
    2) SERVICE ;;
    3) SERVICE ;;
    4) SERVICE ;;
    5) SERVICE ;;
    *) MAIN_MENU "Please enter a valid option."
  esac

}

SERVICE() {
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-5]+$ ]]
  then
    # Send to main menu 
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      # Ask for new customer's name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      # Insert new customer's name and phone number to the database in customers table
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'") # Get the customer_id to be inserted into appointments table
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") # Get the service name from the services table. This will be used for SERVICE_TIME question format.
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *|//') # Remove any space before and after the service name using sed and regex pattern
    # Ask for the service time.
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $(echo $CUSTOMER_NAME | sed -r 's/^ //g')?"
    read SERVICE_TIME
    # After getting the CUSTOMER_ID, SERVICE_ID_SELECTED, AND SERVICE_TIME, Insert them into appointments table
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    # After inserting customer_id, service_id, and time to the appointments table, send to main menu again
    MAIN_MENU "I have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ //g')."
  fi
}

MAIN_MENU
