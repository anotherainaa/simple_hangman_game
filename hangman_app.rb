require 'sinatra'
require 'sinatra/reloader' if development?
require 'tilt/erubis'

require_relative 'hangman'

configure do
  set :port, 5000
  enable :sessions
  set :sessions_secret, 'secret'
end

def reset_game
  session.delete(:game)
  session[:game] ||= HangmanGame.new
end

get '/' do
  reset_game
  erb :index
end

get '/game' do
  game = session[:game]
  @secret_word = game.secret_word
  @remaining_alphabets = game.remaining_alphabets
  @remaining_guesses = game.remaining_guesses
  @alphabets = HangmanGame::ALPHABET

  erb :game
end

def error_for_letter_guess(letter)
  game = session[:game]
  if !game.valid_letter?(letter)
    "Pick a valid letter."
  elsif !game.valid_guess?(letter)
    "Pick a letter that hasn't been picked yet."
  end
end

post '/game' do
  game = session[:game]
  letter = params[:letter_guess].capitalize

  error = error_for_letter_guess(letter)
  if error
    session[:message] = error
    redirect '/game'
  elsif game.correct_guess?(letter)
    game.add_correct_guess(letter)
  elsif !game.correct_guess?(letter)
    game.add_wrong_guess(letter)
    game.decrement_remaining_guess
  end

  redirect '/win' if game.player_won?
  redirect '/gameover' if game.no_remaining_guesses?
  redirect '/game'
end


get '/gameover' do
  game = session[:game]
  @secret_word = game.show_secret_word
  erb :gameover
end

get '/win' do
  erb :win
end

