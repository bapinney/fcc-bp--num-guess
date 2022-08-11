#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
IMIN=1
IMAX=1000
RAND=$(shuf -i $IMIN-$IMAX -n 1)
RANDOM=RAND
echo "Enter your username:"
read USER
RESULT=$($PSQL "SELECT id, username, n_games_played, best_game FROM users WHERE username='$USER'")
BGAME=0
NGAMES=0
USERID=-1
if ! [[ -z $RESULT ]]
then
  echo "$RESULT" | while IFS="|" read ID USERNAME N_GAMES B_GAME
  do
    echo -e "Welcome back, $USERNAME! You have played ${N_GAMES} games, and your best game took ${B_GAME} guesses."
    NGAMES=$N_GAMES
    BGAME=$B_GAME
    FIRSTTIME=0
    USERID=ID
  done
else
  echo -e "Welcome, ${USER}! It looks like this is your first time here."
  FIRSTTIME=1
fi
echo "Guess the secret number between 1 and 1000:"
read GUESS
NGUESSES=1
#You need a space between while [[ ]]!!
while [[ $GUESS != $RAND ]]
do
  if     [ -z "${GUESS##*[!0-9]*}" ]; 
  then   
    echo "That is not an integer, guess again:"
    read GUESS
    continue
  fi
  if [[ $GUESS > $RAND ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  NGUESSES=$((NGUESSES+1))
  read GUESS
done
echo -e "You guessed it in $NGUESSES tries. The secret number was $RAND. Nice job!"
if [[ $FIRSTTIME -eq 1 ]]
then
  RESULT=$($PSQL "INSERT INTO users(username, n_games_played, best_game) VALUES('$USER', 1, $NGUESSES)")
else
  BGAME=$($PSQL "SELECT best_game FROM users WHERE username='$USER'")
  NGAMES=$((NGAMES+1))
  if [[ $NGUESSES -lt $BGAME ]]
  then
    BGAME=$((NGUESSES))
  fi
  echo -e "UPDATE users SET n_games_played = $NGAMES, best_game = $BGAME WHERE username='$USER'"
  RESULT=$($PSQL "UPDATE users SET n_games_played = $NGAMES, best_game = $BGAME WHERE username='$USER'")
fi
