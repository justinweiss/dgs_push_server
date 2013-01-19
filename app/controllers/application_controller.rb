class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def render_404(message = "Not Found")
    ASN.instrument('dgs.request.status_404')
    raise ActionController::RoutingError.new(message)
  end
end
