# Hangman

The goal of this project was to build a simple command line Hangman game in Ruby, where one player plays against the computer, with the word randomly selected from a dictionary and with the ability to save the game.

To play the game, run the command `$ ruby lib/hangman.rb` from within the project directory.

* There are three save files to choose from within the game.
* Upon starting the game, you are given the choice whether to start a new game or load a previous game from a save file.
* After each round, you are given the option to save.
* The game class is serialized into JSON during save/load and stored in text files in the project directory.
* The word you have to guess is a randomly selected 5-12 letter word from the dictionary.txt file. This file consists of the contents of the 5desk.txt dictionary file from http://scrapmaker.com/