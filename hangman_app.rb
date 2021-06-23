require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'


ALPHABET = ("A".."Z").to_a

configure do
  set :port, 5000
  enable :sessions
  set :sessions_secret, 'secret'
end

def generate_secret_word
  words = ["easy", "medium", "mastery", "assessment", "advanced", "launch school", "not yet"]
  words.sample.upcase
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
  def display_secret_word(word)
    word.chars.map do |letter|
      if session[:correct_guesses].include?(letter)
        " #{letter} "
      elsif letter =~ /[^A-Z]/
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

def error_for_letter_guess(letter)
  remaining_alphabets = ALPHABET - session[:correct_guesses] - session[:wrong_guesses]
  if !ALPHABET.include?(letter)
    "Pick a valid letter."
  elsif !remaining_alphabets.include?(letter)
    "Pick a letter that hasn't been picked."
  end
end

def player_won?
  session[:secret_word].delete("^A-Z").chars.all? do |letter|
    session[:correct_guesses].include?(letter)
  end
end

def no_remaining_guesses?
  session[:remaining_guesses] == 0
end

def check_game_status
  redirect '/win' if player_won?
  redirect '/gameover' if no_remaining_guesses?
end

post '/game' do
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

  check_game_status
  redirect '/game'
end

def reset_game
  session.delete(:secret_word)
  session.delete(:correct_guesses)
  session.delete(:wrong_guesses)
  session.delete(:remaining_guesses)
end

get '/gameover' do
  @secret_word = session[:secret_word]
  erb :gameover
end

get '/win' do
  erb :win
end

