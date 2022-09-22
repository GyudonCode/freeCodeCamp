#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


# Clearing all tables in our DB for the first load
echo "$($PSQL "TRUNCATE teams, games")"


#kay, inserting teams - expected +24 rows on teams table

#INSERT WINNERS - main loop - reading file in these variables
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #condition to ignore first line
  if [[ $YEAR != year ]]
  then
    # getting team_id - checking if team exits in db
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # if team id is empty means that doesn't exits in DB, so we have to insert that team
    if [[ -z $TEAM_ID ]]
    then
      # inserting team
      echo="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
    fi

    # getting next team_id to keep the loop working - wheter we inserted or not
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  fi
done

#INSERT OPPONENTS - main loop - reading file in these variables
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #condition to ignore first line
  if [[ $YEAR != year ]]
  then
    # getting team_id - checking if team exits in db
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if team id is empty means that doesn't exits in DB, so we have to insert that team
    if [[ -z $TEAM_ID ]]
    then
      # inserting team
      echo="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
    fi

    # getting next team_id to keep the loop working - wheter we inserted or not
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi
done



# Now we inserting games data
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #condition to ignore first line
  if [[ $YEAR != year ]]
  then
    # get team_id of winner
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # get team_id of loser
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # getting game_id - checking if game exits in db
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year='$YEAR' AND round='$ROUND' AND winner_id='$WINNER_ID' AND opponent_id='$OPPONENT_ID' AND winner_goals='$WINNER_GOALS' AND opponent_goals='$OPPONENT_GOALS'")

    # if game id is empty means that doesn't exits in DB, so we have to insert that game
    if [[ -z $GAME_ID ]]
    then
      # inserting game
      echo="$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")"
    fi

    # getting next team_id to keep the loop working - wheter we inserted or not
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi
done


