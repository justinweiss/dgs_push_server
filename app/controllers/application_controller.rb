class ApplicationController < ActionController::Base
  protect_from_forgery

  # Skip protect_from_forgery for API calls
  # TODO: Figure out a real way of handling these.
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
end
