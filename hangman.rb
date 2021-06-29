require 'yaml'

class HangmanGame
  attr_reader :correct_guesses, :wrong_guesses, :remaining_guesses

  ALPHABET = ("A".."Z").to_a

  def initialize
    generate_secret_word
    @correct_guesses = []
    @wrong_guesses = []
    @remaining_guesses = 7
  end

  def generate_secret_word
    wordbank = Psych.load_file("./wordbank.yml")
    @secret_word = wordbank.sample.upcase
  end

  def valid_letter?(letter)
    ALPHABET.include?(letter)
  end

  def valid_guess?(letter)
    remaining_alphabets.include?(letter)
  end

  def show_secret_word
    @secret_word
  end

  def secret_word
    @secret_word.chars.map do |letter|
      if @correct_guesses.include?(letter)
        " #{letter} "
      elsif letter =~ /[^A-Z]/
        " #{letter} "
      else
        " _ "
      end
    end.join
  end

  def player_won?
    @secret_word.delete("^A-Z").chars.all? { |letter| @correct_guesses.include?(letter) }
  end

  def no_remaining_guesses?
    @remaining_guesses == 0
  end

  def remaining_alphabets
    ALPHABET - @correct_guesses - @wrong_guesses
  end

  def correct_guess?(letter)
    @secret_word.include?(letter)
  end

  def add_correct_guess(letter)
    @correct_guesses << letter
  end

  def add_wrong_guess(letter)
    @wrong_guesses << letter
  end

  def decrement_remaining_guess
    @remaining_guesses -= 1
  end
end

