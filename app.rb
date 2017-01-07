require 'sinatra'
require 'sinatra/reloader' if development? 

enable :sessions

get '/' do
	new_game
	set_state
	erb :index
end

post '/' do
	guess = params['guess'].downcase if params['guess'] != nil
	check_guess(guess)
	set_display
	set_message
	set_state
	erb :index
end

helpers do

	def set_state
		@secret_word = session[:secret_word]
		@number_of_guesses = session[:number_of_guesses]
		@guesses = session[:guesses]
		@display = session[:display]
		@message = session[:message]
	end

	def new_game
		dictionary = File.readlines('5desk.txt')
		session[:secret_word] = get_secret_word(dictionary)
		session[:number_of_guesses] = 6
		session[:guesses] = []
		session[:display] = set_display
		session[:message] = "Guess a letter!"
		session[:guess] = nil
	end

	def get_secret_word(dictionary)
		word = ""
		while word.length() < 5 || word.length() > 12
			word = dictionary.sample().strip().downcase()
		end
		return word
	end

	def set_display
		session[:display] = session[:secret_word].split(//).map do |c| 
			session[:guesses].include?(c) ? c.upcase : "__"
		end.join(" ")
	end

	def win?
		session[:secret_word].split(//).each {|c| return false if !session[:guesses].include?(c) }
		return true
	end

	def lose?
		session[:number_of_guesses] == 0 && !win?
	end

	def set_message
		if win?
			session[:message] = "Congratulations! You Win!"
		elsif lose?
			session[:message] = "Sorry you ran out of guesses!" \
													" The secret word was #{session[:secret_word]}"
		else
			session[:message] = "Keep guessing!"
		end
	end

	def check_guess(guess)
		if valid_guess?(guess)
			session[:guesses] << guess 
			session[:number_of_guesses] -= 1 if incorrect_guess(guess)
		end
	end

	def valid_guess?(guess)
		return true if !session[:guesses].include?(guess) && guess != nil
	end

	def incorrect_guess(guess)
		return true if !session[:secret_word].split(//).include?(guess) 
	end
	
end