ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/mock'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def encode_device_token(device_token)
    Base64.encode64([device_token].pack("H*"))
  end

  # Generates a DGS status-style list of games based on the data
  # passed in. Currently, you can specify the following parameters:
  #
  # game_id, opponent_name, last_move_date
  def game_list(games_data = [])
    game_list_string = ""
    last_move_date_format = "%Y-%m-%d %H:%M:%S"
    Array(games_data).each_with_index do |game, i|
      game_id = game.fetch(:game_id, i)
      opponent_name = game.fetch(:opponent_name, "opponent{i}")
      last_move_date = game.fetch(:last_move_date, i.minutes.ago)
      game_list_string << "G,#{game_id},'#{opponent_name}',B,'#{last_move_date.strftime(last_move_date_format)}','J: 83d 14h (+ 1d * 10)',2,PLAY,62,0,0,'GO',0,'2007-05-27 15:00:00'\n"
    end
    game_list_string
  end
end
