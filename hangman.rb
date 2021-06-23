class HangmanGame
  ALPHABET = ("A".."Z").to_a

  def initialize
    words = ["EASY", "MEDIUM"]
    @secret_word = words.sample
    @correct_guesses = []
    @wrong_guesses = []
    @remaining_guesses = 7
  end

  def play
    display_welcome_message
    loop do
      display_guesses_remaining
      display_board
      player_guess_letter
      @remaining_guesses -= 1
      break if player_won? || @remaining_guesses == 0
    end
    display_board
    display_result
    display_goodbye_message
  end

  def player_won?
    @secret_word.chars.all? { |letter| @correct_guesses.include?(letter) }
  end

  def display_result
    if player_won?
      puts "You won!"
    else
      puts "No more guesses left! You lose!"
    end
    puts ""
  end


  def display_guesses_remaining
    puts "You have #{@remaining_guesses} guesses left."
    puts ""
  end

  def display_welcome_message
    puts "Welcome to Hangman!"
    puts ""
  end

  def display_board
    word = @secret_word.chars.map do |letter|
      if @correct_guesses.include?(letter)
        " #{letter} "
      else
        " _ "
      end
    end.join
    puts word
    puts
  end

  def display_goodbye_message
    puts "Thanks for playing!"
    puts "Goodbye!"
  end

  def player_guess_letter
    puts "Pick a letter:"
    puts ALPHABET.join("-")
    letter = gets.chomp.upcase

    if @secret_word.chars.include?(letter)
      @correct_guesses << letter
    elsif !@secret_word.chars.include?(letter)
      @wrong_guesses << letter
    end
    puts ""
  end
end

game = HangmanGame.new
game.play
