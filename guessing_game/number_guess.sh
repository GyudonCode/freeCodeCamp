
#!/bin/bash

#PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"


#--------------- LOGIN ----------------
echo -e "\nEnter your username:"
read USERNAME

#---------- asks DB if it exists-------------------------------------
USERNAME_EXISTS_RESULT=$($PSQL "SELECT games, best_score 
                        FROM users 
                        WHERE username='$USERNAME'") 

if [[ -z $USERNAME_EXISTS_RESULT ]]
then
#------------ User not found ----------------------------------------
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  USERNAME_INSERT_RESULT=$($PSQL "INSERT INTO users(username,best_score,games)
                            VALUES('$USERNAME',0,0)")
else
#----------------- User found ----------------------------------------
  echo "$USERNAME_EXISTS_RESULT" | while read GAMES BAR BEST
  do
    echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
  done
fi

#----------- RANDOM GENERATOR -----------

echo "Guess the secret number between 1 and 1000:"

RANDOM_NUMBER=$(( RANDOM % 1001))
USER_ANSWER=9999
NUMBER_OF_GUESSES=0

echo $RANDOM_NUMBER

#---------------------ANSWERS LOOP --------------------------------------------------------
while [[ $USER_ANSWER != $RANDOM_NUMBER ]]
do
  read USER_ANSWER 

  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))

  if [[ $USER_ANSWER =~ ^[0-9]*$ ]]
  then
    #NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))

    if [[ $USER_ANSWER > $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi

    if [[ $USER_ANSWER < $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
#---------------------- win ----------------------------------------
    if [[ $USER_ANSWER = $RANDOM_NUMBER ]]
    then
      #NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES-1))
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      
      
      #add 1 more game to games counter
      GAMES=$(($GAMES+1)) 


      RESULT=$($PSQL "SELECT best_score 
                      FROM users 
                      WHERE username='$USERNAME'") 
      
      echo "$RESULT" | while read BEST
      do
        #if user did a personal best score, that becomes the new best score
        if [[ $BEST > $NUMBER_OF_GUESSES ]]
        then
          BEST=$NUMBER_OF_GUESSES
        fi

        if [[ $BEST = 0 ]]
        then
          BEST=$NUMBER_OF_GUESSES
        fi

        UPDATE_RESULT=$($PSQL "UPDATE users SET games=$GAMES, best_score=$BEST WHERE username='$USERNAME'")
      done
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done
