# frozen_string_literal: true

# Module for game logic (Logic)
module Logic
  # Method that gets a random word from dictionary (pull_word)
  def pull_word
    lines = File.readlines 'dictionary.txt'
    word = ''
    while word.length < 5 || word.length > 12
      random_number = rand(61_406)
      word = lines[random_number].chomp
    end
    word
  end

  # Method that sets @word as the random word (set_word)
  def set_word
    @word = pull_word
  end

  # Method that sets player name
  def set_name(name)
    @name = name
  end

  # Method that sets @letter as inputted letter (set_letter)
  def set_letter(letter)
    @letter = letter
  end

  # Method that sets guess array as an array of same length as the random word with * default values (set_guess)
  def set_guess
    @guess = Array.new(@word.length, '*')
  end

  # Method that adds the correct letters to guess array (add_to_guess)
  def add_to_guess
    @guess = @guess.map!.with_index do |character, index|
      @word.downcase[index] == @letter ? @word[index] : character
    end
  end

  # Method that decrements the lives (take_life)
  def take_life
    @lives -= 1
  end

  # Method that checks whether selected letter is present in the random word (check_choice)
  def check_choice
    @word.downcase.include?(@letter)
  end

  # Method that adds guessed letter into bank of guessed letters (add_to_bank)
  def add_to_bank
    @bank.push(@letter)
  end

  # Method that checks whether game is won (check_winner)
  def check_winner
    @word.downcase.chars == @guess
  end
end

# Module for graphical display (Display)
module Display
  # Method that prints the guess array (show_guess)
  def show_guess
    @guess.each { |character| print "#{character} " }
    print "\n"
  end

  # Method that displays the lives (show_lives)
  def show_lives
    puts "Lives: #{@lives} ♥"
  end

  # Method that displays the bank of guessed letters (show_bank)
  def show_bank
    print 'Used letters: '
    @bank.each { |letter| print "#{letter} " }
    print "\n"
  end

  # Method that shows the secret word
  def show_word
    print "The word was: #{@word} \n"
    puts "\n"
  end

  # Method that displays winning message (show_win)
  def show_win
    puts "Congratulations #{@name}, you've won the game!"
    puts 'Hangman lives to hang another day!'
    puts "\n"
  end

  # Method that displays losing message (show_lose)
  def show_lose
    puts "Uh oh... #{@name}... I think he's dead..."
    puts 'You need to do better next time!'
    puts "\n"
  end
end

# Module for user input (Input)
module Input
  # Method that asks for player's name (ask_name)
  def ask_name
    puts 'What is your name?'
    print 'Name: '
    name = gets.chomp
    puts "\n\n"
    name
  end

  # Method that asks player to select a letter, or say that they want to save the game (ask_letter)
  def ask_letter
    puts "Please select a letter or type 'save' to save game"
    correct_input = 0
    until correct_input == 1
      print 'Letter: '
      letter = gets.chomp.downcase
      if letter.length == 1 && letter.match(/[A-z]/) && !@bank.include?(letter)
        correct_input = 1
      elsif letter == 'save'
        puts "\n\n\n"
        save
        show_guess
        show_lives
        show_bank
        puts ''
      else
        puts 'PLEASE ENTER A LETTER WHICH HAS NOT BEEN USED'
      end
    end
    puts "\n\n"
    letter
  end

  # Method that asks user what save file they want to use (ask_save_file)
  def ask_save_file
    puts 'What save file would you like to use?'
    puts ''
    puts '1  2  3'
    puts ''
    correct_input = 0
    until correct_input == 1
      print 'Save file number: '
      save_file = gets.chomp
      if %w[1 2 3].include?(save_file)
        correct_input = 1
      else
        puts 'PLEASE ENTER A NUMBER FROM 1-3'
      end
    end
    puts "\n\n"
    "save_file_#{save_file}.txt"
  end

  # Method that asks user what menu option they want to select (ask_menu_option)
  def ask_menu_option
    puts 'What would you like to do?'
    puts ''
    puts '1. Start New Game'
    puts '2. Load Game From Save File'
    puts ''
    correct_input = 0
    until correct_input == 1
      print 'Enter a number: '
      option = gets.chomp
      if %w[1 2].include?(option)
        correct_input = 1
      else
        puts 'PLEASE ENTER 1 OR 2'
      end
    end
    puts "\n\n"
    option
  end

  # Method that asks the player if they want to play again (ask_play_again)
  def ask_play_again
    correct_input = 0
    until correct_input == 1
      print 'Do you want to play again? (y/n): '
      option = gets.chomp.downcase
      if %w[y n].include?(option)
        correct_input = 1
      else
        puts 'PLEASE ENTER Y OR N'
      end
    end
    puts "\n\n"
    option
  end

  #
end

# Class for hangman game (Game)
class Game
  include Logic
  include Display
  include Input

  require 'json'

  attr_reader :guess
  attr_reader :word
  attr_reader :name

  # Instance variables
  def initialize
    # Player name (name)
    @name = 'name'

    # Guess array (guess)
    @guess = []

    # Random word (word)
    @word = ''

    # Guessed letter bank (bank)
    @bank = []

    # Lives (lives)
    @lives = 7

    # Current guessed letter
    @letter = ''
  end

  # Method that serializes essential game data into JSON
  def serialize
    data = {
      name: @name,
      guess: @guess,
      word: @word,
      bank: @bank,
      lives: @lives,
      letter: @letter
    }
    data.to_json
  end

  # Method that unserializes JSON game data
  def unserialize(string)
    data = JSON.parse(string)
    data
  end

  # Method that sets up game (setup)
  def setup
    set_name(ask_name)
    set_word
    set_guess
  end

  # Method that plays one round
  def round
    show_guess
    show_lives
    show_bank
    puts ''
    set_letter(ask_letter)
    add_to_bank
    add_to_guess
    take_life unless check_choice
  end

  # Method that controls the sequence of game rounds
  def round_sequence
    win_flag = false
    while @lives >= 0 && win_flag == false
      round
      win_flag = check_winner
    end
    win_flag ? show_win : show_lose
    show_word
  end

  # Method that plays game (play)
  def play
    choice = ask_menu_option
    choice == '1' ? setup : load
    continue = 1
    while continue == 1
      round_sequence
      if ask_play_again == 'y'
        reset
      else
        continue = 0
        puts 'Goodbye!'
        puts "\n\n"
      end
    end
  end

  # Method that resets the game (reset)
  def reset
    @lives = 7
    @letter = ''
    @bank = []
    @guess = []
    @word = ''
    set_word
    set_guess
  end

  # Method that saves the current game (save)
  def save
    file_name = ask_save_file
    save_file = File.open(file_name, 'w')
    save_file.puts(serialize)
    save_file.close
    puts "Game has been saved to Save File #{file_name[-5]}!"
    puts "\n\n"
  end

  # Method that loads a game file (load)
  def load
    file_name = ask_save_file
    save_file = File.open(file_name, 'r')
    save_file.pos = 0
    contents = unserialize(save_file.read)
    @name = contents['name']
    @guess = contents['guess']
    @word = contents['word']
    @bank = contents['bank']
    @lives = contents['lives']
    @letter = contents['letter']
    puts "Game has been loaded from Save File #{file_name[-5]}!"
    puts "\n\n"
  end
end

game = Game.new

game.play
