#!/bin/bash

# Script to interact with salon database

# PSQL variable
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# title
echo -e "\n~~~*~~ Curl Up & Dye Salon ~~*~~~\n"

# main menu - done
MAIN_MENU() {
  # if called with a message as an argument, print the message
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome! Please select a service to make your appointment:"

  # 1. Request Appointment
  # 2. Exit.
DISPLAY_SERVICES
}

# display services - TODO
DISPLAY_SERVICES() {
    # title
    echo -e "\n~~~ Available Services ~~~\n"
    # get services
    SERVICES=$($PSQL "SELECT * FROM services;")
    # display services
    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
    # get user service selection
    read SERVICE_ID_SELECTED
    # validate selection
    # # if not a number
    # if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    # then
    # MAIN_MENU 'Please enter a valid service number.'
    # fi
    # if not an available service
    SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_RESULT ]]
    then
      MAIN_MENU 'Please select an available service.'
    else
      # book service
      # get customer information
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      # check if customer exists
      CUSTOMER_PHONE_RESULT=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if customer not found, add customer
      if [[ -z $CUSTOMER_PHONE_RESULT ]]
      then
        echo -e "\nJust a moment while we add you to our system. What's your first name?"
        read CUSTOMER_NAME
        echo "Hi, $CUSTOMER_NAME"
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      # if customer found, book service
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo -e "\nWhat time would you like to come in?"
      read SERVICE_TIME
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
    fi
}

# exit - done
EXIT() {
    echo -e "\nThanks for coming!"
}

# script
MAIN_MENU