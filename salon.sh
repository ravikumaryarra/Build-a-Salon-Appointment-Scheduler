#! /bin/bash

# Connect to the database
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Function to display services
display_services() {
  echo "Welcome to the Salon!"
  echo "Here are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Display services initially
display_services

# Prompt for service
while true
do
  echo -e "\nPlease select a service by entering the service ID:"
  read SERVICE_ID_SELECTED

  # Check if valid service ID
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -n $SERVICE_NAME ]]
  then
    break
  else
    echo -e "\nInvalid service ID. Please try again."
    display_services
  fi
done

# Prompt for phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]
then
  # Prompt for new customer name
  echo -e "\nIt seems you are a new customer. Please enter your name:"
  read CUSTOMER_NAME
  # Insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Prompt for appointment time
echo -e "\nEnter the time you would like to book the appointment:"
read SERVICE_TIME

# Insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Output confirmation message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
