require 'net/http'
class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end
  def uses_grid_letters_incorrectly?(attempt, grid)
    # Checks to see if an attempt uses any letters not in the grid,
    # or uses any letter more times than it appears in the grid.
    remaining_letters = grid
    attempt.upcase.chars.each do |letter|
      return true unless grid.include?(letter)
      remaining_letters.delete_at(remaining_letters.index(letter))
    end
    return false
  end
  def invalid_english_word?(attempt)
    # Use the Le Wagon dictionary to check if a word exists.
    url = URI("https://wagon-dictionary.herokuapp.com/#{attempt}")
    serialized_response = Net::HTTP.get(url)
    dictionary_response = JSON.parse(serialized_response)
    return !dictionary_response["found"]
  end
  def score
    letters = params[:letters].split(' ')
    attempt = params[:attempt]
    if uses_grid_letters_incorrectly?(attempt, letters)
      @response = "Sorry, but #{attempt} cannot be build out of #{letters.join(' ')}."
    elsif invalid_english_word?(attempt)
      @response = "Sorry, but #{attempt} is not an English word."
    else
      @response = "Congratulations, #{attempt} is a valid word!"
      cookies[:score] = cookies[:score].to_i + 10
    end
  end
end
