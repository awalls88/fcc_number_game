#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~ Number Game ~~~~~\n"

#generate random number between 1 and 1k.
RANDOM_NUMBER=$(( ( RANDOM % 1000 )  + 1 ))

USERNAME (){
  echo -e "\nEnter your username:\n"
  read USERNAME
  USERNAME_CHARACTERS=${#USERNAME}
  if 
    [[ $USERNAME_CHARACTERS -lt 23 ]]
    then
    USERNAME_QUERY
    else
    echo -e "\nThat username is not valid, please enter a username less than twenty-two characters."
    USERNAME
  fi
}


USERNAME_QUERY () {
  ##query for username 
  RETURN_USER=$($PSQL "SELECT username FROM number_guess WHERE username = '$USERNAME'")
    if [[ -z $RETURN_USER ]]
      then
      ADD_USER=$($PSQL "INSERT INTO number_guess(username) VALUES ('$USERNAME')")
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
      GUESS
      TRIES=0
      NUMBER_GAMES=0
      else
      ##user found
      NUMBER_GAMES=$($PSQL "SELECT played_games FROM number_guess WHERE username = '$USERNAME'")
      BEST_GAME=$($PSQL "SELECT best_game FROM number_guess WHERE username = '$USERNAME'")
      echo -e "\nWelcome back, $RETURN_USER! You have played $NUMBER_GAMES games, and your best game took $BEST_GAME guesses." 
      TRIES=0
      GUESS
    fi
}



GUESS (){
  echo -e "\nGuess the secret number between 1 and 1000:\n"
  read INPUT
  INPUT=$INPUT

    #not an integer
    if [[ ! $INPUT =~ ^[0-9]+$ ]]
      then
        echo -e "That is not an integer, guess again:\n"
        GUESS
      elif [[ $INPUT -lt $RANDOM_NUMBER ]]
      then
        echo -e "It's higher than that, guess again:\n"
        TRIES=$((TRIES+1))
        GUESS
      elif [[ $INPUT -gt $RANDOM_NUMBER ]]
      then
        echo -e "It's lower than that, guess again:\n"
        TRIES=$((TRIES+1))
        GUESS
      else
        TRIES=$((TRIES+1))
        NUMBER_GAMES=$((NUMBER_GAMES+1))
        echo -e "\nYou guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
        if [[ -z $BEST_GAME || $BEST_GAME > $TRIES ]] 
          then
            # update best game and total games
            UPDATE_USER_RESULT="$($PSQL "UPDATE number_guess SET played_games = $NUMBER_GAMES, best_game = $TRIES WHERE username = '$USERNAME'")"
          else 
            # otherwise only update total games
            UPDATE_USER_RESULT="$($PSQL "UPDATE number_guess SET played_games = $NUMBER_GAMES WHERE username = '$USERNAME'")"
         fi
        fi
    exit 0
}
USERNAME
