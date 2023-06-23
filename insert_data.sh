#! /bin/bash
if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do
  if [[ $WINNER != "winner" ]]
  then
    for i in {0..1}
    do
      if [[ $i = 0 ]]
      then
        TEAM=$WINNER
      else
        TEAM=$OPPONENT
      fi
      # get team_id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      #echo ${TEAM[i]}
      # if not found
      if [[ -z $TEAM_ID ]]
      then
        # insert team
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
        if [[ $INSERT_TEAM_RESULT = "INSERT 0 1" ]]
        then
          echo Inserted into teams, $TEAM
        fi
        # get new team_id
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      fi
      if [[ $i = 0 ]]
      then
        WINNER_ID=$TEAM_ID
      else
        OPPONENT_ID=$TEAM_ID
      fi
    done
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WGOALS, $OGOALS)")
    if [[ $INSERT_GAME_RESULT = "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR $ROUND
    fi
  fi
done
