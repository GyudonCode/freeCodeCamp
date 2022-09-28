
#!/bin/bash

#This program will retrieve info about periodic table elements from DB

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
INPUT=$1

SELECTOR() {
#------------------------NO ARGUMENTS-----------------------  
  if [[ -z $INPUT ]]
  then
    echo "Please provide an element as an argument."
  else
  
#---------------------NOT NUMERIC ARGUMENT-------------------
    if [[ ! $INPUT =~ ^[0-9]*$ ]]
    then
#-----------------ELEMENT SYMBOL ARGUMENT-------------------
      if [[ $INPUT =~ ^[a-zA-Z]{1,2}$ ]]
      then
        ELEMENT_SYMBOL_SEARCH
      else

#------------------ELEMENT NAME ARGUMENT--------------------
        ELEMENT_NAME_SEARCH
      fi
  
#--------------------ATOMIC NUMBER SEARCH-------------------    
      else
        ATOMIC_NUMBER_SEARCH
      fi
  fi
}

ATOMIC_NUMBER_SEARCH(){
  SEARCH_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius
                         FROM elements 
                         FULL JOIN properties USING(atomic_number)
                         FULL JOIN types USING(type_id)
                         WHERE atomic_number='$INPUT'")
  SHOW_RESULT
}

ELEMENT_SYMBOL_SEARCH(){
  SEARCH_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius
                         FROM elements 
                         FULL JOIN properties USING(atomic_number)
                         FULL JOIN types USING(type_id)
                         WHERE symbol='$INPUT'")
  SHOW_RESULT
}

ELEMENT_NAME_SEARCH(){
  SEARCH_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius
                         FROM elements 
                         FULL JOIN properties USING(atomic_number)
                         FULL JOIN types USING(type_id)
                         WHERE name='$INPUT'")
  SHOW_RESULT
}

SHOW_RESULT(){
  if [[ -z $SEARCH_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$SEARCH_RESULT" | while read ATOMIC_NUMBER BAR ELEMENT_NAME BAR ELEMENT_SYMBOL BAR ELEMENT_TYPE BAR ELEMENT_MASS BAR MELTING_POINT BAR BOILING_POINT
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $ELEMENT_TYPE, with a mass of $ELEMENT_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius." 
    done
  fi
}


SELECTOR
