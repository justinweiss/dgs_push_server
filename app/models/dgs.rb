class DGS
  class Exception < ::RuntimeError; end
  class NotLoggedInException < DGS::Exception; end

  private
  attr_reader :connection, :host, :base_path

  public

  def initialize
    @config = YAML.load_file(File.expand_path('config/dgs.yml', Rails.root))[Rails.env]
    @host = @config['host']
    @base_path = @config['base_path']
    @connection = Faraday.new(:url => host) do |faraday|
      faraday.response :logger # log requests to STDOUT
      faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  # Performs the DGS GET request at /path with parameters and returns
  # the response body. Mostly used as a building block for higher
  # level calls, and as a method that can be easily mocked in tests.
  def get(session, path)
    response = connection.get(path) do |request|
      unless session.expired?
        request.headers['Cookie'] = session.cookie
      end
    end
    handle_errors(response)
    body = response.body
  end

  private

  # Handle login errors, anything else DGS sends our way
  def handle_errors(response)
    raise DGS::NotLoggedInException, response.body if response.body.match("\\[#Error: unknown_user;")
  end

  def request_path(path)
    File.join(base_path, path)
  end
end
