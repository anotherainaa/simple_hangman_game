require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'


ALPHABET = ("A".."Z").to_a

configure do
  set :port, 9494
  enable :sessions
  set :sessions_secret, 'secret'
end

def generate_secret_word
  words = ["EASY", "MEDIUM", "WASHINGTON", "CATERPILLAR"]
  words.sample
end

def initialize_game
  session[:correct_guesses] ||= []
  session[:wrong_guesses] ||= []
  session[:remaining_guesses] ||= 7
  session[:secret_word] ||= generate_secret_word
end

before '/game' do
  initialize_game
end

helpers do
  def display_word(word)
    word.chars.map do |letter|
      if session[:correct_guesses].include?(letter)
        " #{letter} "
      else
        " _ "
      end
    end.join
  end
end

get '/' do
  reset_game
  erb :index
end

get '/game' do
  @secret_word = session[:secret_word]
  @remaining_alphabets = ALPHABET - session[:correct_guesses] - session[:wrong_guesses]
  @remaining_guesses = session[:remaining_guesses]

  erb :game
end

def player_won?
  session[:secret_word].chars.all? { |letter| session[:correct_guesses].include?(letter) }
end

def error_for_letter_guess(letter)
  remaining_alphabets = ALPHABET - session[:correct_guesses] - session[:wrong_guesses]
  if !ALPHABET.include?(letter)
    "Pick a valid letter."
  elsif !remaining_alphabets.include?(letter)
    "Pick a letter that hasn't been picked."
  end
end

post '/game/:letter_guess' do
  letter = params[:letter_guess].capitalize

  error = error_for_letter_guess(letter)
  if error
    session[:message] = error
    redirect '/game'
  elsif session[:secret_word].include?(letter)
    session[:correct_guesses] << letter
  elsif !session[:secret_word].chars.include?(letter)
    session[:wrong_guesses] << letter
    session[:remaining_guesses] -= 1
  end

  if session[:remaining_guesses] == 0
    redirect '/gameover'
  elsif player_won?
    redirect '/win'
  else
    redirect '/game'
  end
end

def reset_game
  session.delete(:secret_word)
  session.delete(:correct_guesses)
  session.delete(:wrong_guesses)
  session.delete(:remaining_guesses)
end

get '/gameover' do
  erb :gameover
end

get '/win' do
  erb :win
end

