#!/bin/bash

RANDOM_NUMBER=$(($RANDOM % (1 - 1000 + 1) + 1))

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

SAVED_USERNAME=$($PSQL "SELECT * FROM contestants WHERE name = '$USERNAME';")

if [[ -z $SAVED_USERNAME ]]
then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
else
    echo "$SAVED_USERNAME" | while IFS="|" read NAME GAMES_PLAYED BEST_GAME
    do
        echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

GUESS_COUNT=1

while [ $GUESS != $RANDOM_NUMBER ];
do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
        echo "That is not an integer, guess again:"
        read GUESS
    elif [[ $GUESS > $RANDOM_NUMBER ]]
    then
        echo "It's lower than that, guess again:"
        read GUESS
        ((GUESS_COUNT++))
    else
        echo "It's higher than that, guess again:"
        read GUESS
        ((GUESS_COUNT++))
    fi
done

if [[ -z $SAVED_USERNAME ]]
then
    INSERT_CONTESTANT=$($PSQL "INSERT INTO contestants(name, games_played, best_game) VALUES('$USERNAME', 1, $GUESS_COUNT);")
else
    echo "$SAVED_USERNAME" | while IFS="|" read NAME GAMES_PLAYED BEST_GAME
    do
        if [[ $BEST_GAME -le $GUESS_COUNT ]]
        then
            UPDATE_CONTESTANT=$($PSQL "UPDATE contestants SET games_played = $GAMES_PLAYED + 1 WHERE name = '$NAME'")
        else
            UPDATE_CONTESTANT=$($PSQL "UPDATE contestants SET games_played = $GAMES_PLAYED + 1 WHERE name = '$NAME'")
            UPDATE_CONTESTANT=$($PSQL "UPDATE contestants SET best_game = $GUESS_COUNT WHERE name = '$NAME'")
        fi
    done
fi

echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
