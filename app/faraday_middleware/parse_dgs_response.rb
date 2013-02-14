class ParseDGSResponse < Faraday::Response::Middleware
  def on_complete(env)
    if env[:body]
      reencode_body(env)
      handle_errors(env)
    end
  end

  private

  def reencode_body(env)
    env[:body].encode('UTF-8', invalid: :replace, undef: :replace)
  end

  def handle_errors(env)
    if had_login_errors?(env)
      env[:status] = 401
      raise DGS::NotLoggedInException, env[:body]
    else
      handle_other_errors(env)
    end
  end

  def had_login_errors?(env)
    login_errors = %w(not_logged_in wrong_userid wrong_password cookies_disabled login_denied no_uid unknown_user)
    env[:body].match("Error: (#{login_errors.join('|')})")
  end

  def handle_other_errors(env)
    raise DGS::Exception, env[:body] if env[:body].match(/Error:/)
  end
end
