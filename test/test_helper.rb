ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/mock'
require 'webmock/minitest'
require 'sidekiq/testing'
require 'helpers/fetch_games_worker_tests'
WebMock.disable_net_connect!

module JSONRequiredTest
  # Force the format to JSON, otherwise we'll get all kinds of routing
  # errors :-/
  def process(action, http_method = 'GET', parameters = nil, session = nil, flash = nil)
    parameters = {format: :json}.merge(parameters) if parameters
    super(action, http_method, parameters, session, flash)
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

  # The DGS mock 'primitive'. This yields (and returns) a mock of a
  # sole copy of the DGS server that all requests inside the block
  # will use when making requests.
  def mock_dgs
    dgs = MiniTest::Mock.new
    DGS::ConnectionPool.stub(:checkout, dgs) do
      DGS::ConnectionPool.stub(:checkin, nil) do
        yield dgs
      end
    end
    dgs
  end

  # Mocks the DGS connection, responding with +response+. If response
  # is callable, calls it and returns the return value of the callable.
  def mock_dgs_with_response(response, session = players(:justin).session)
    mock_dgs do |dgs|
      dgs.expect(:get, response, [session, "/quick_status.php?version=2"])
      yield
    end.verify
  end

  # Mocks a Session test request, returning +handle+, made with +session+.
  def mock_session_test_request(handle = players(:justin).handle, session = players(:justin).session)
    mock_dgs do |dgs|
      dgs.expect(:get, {:handle => handle}.to_json, [session, '/quick_do.php?obj=user&cmd=info'])
      yield
    end
  end

  # Mocks a session test request with a new Session constructed from
  # +session_params+, returning +handle+.
  def mock_dgs_with_new_session(session_params, handle = players(:justin).handle)
    new_session = Session.new(session_params)
    Session.stub(:new, new_session) do
      mock_session_test_request(handle, new_session) do
        yield
      end
    end
  end
end
