ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/mock'

module JSONRequiredTest
  # Force the format to JSON, otherwise we'll get all kinds of routing
  # errors :-/
  def process(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
    parameters = {format: :json}.merge(parameters) if parameters
    super(action, parameters, session, flash, http_method)
  end
end

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

  def game_csv(game_count)
    game_data = []
    game_count.times do
      game_data << {}
    end
    csv_for_game_data(game_data)
  end

  # Generates a DGS status-style list of games based on the data
  # passed in. Currently, you can specify the following parameters:
  #
  # game_id, opponent_name, updated_at
  def csv_for_game_data(games_data = [])
    game_list_string = ""
    last_move_date_format = "%Y-%m-%d %H:%M:%S"
    Array(games_data).each_with_index do |game, i|
      game_id = game.fetch(:dgs_game_id, 1000 + i)
      opponent_name = game.fetch(:opponent_name, "opponent#{i}")
      updated_at = game.fetch(:updated_at, i.minutes.ago)
      game_list_string << "G,#{game_id},'#{opponent_name}',B,'#{updated_at.strftime(last_move_date_format)}','J: 83d 14h (+ 1d * 10)',2,PLAY,62,0,0,'GO',0,'2007-05-27 15:00:00'\n"
    end
    game_list_string
  end
end
