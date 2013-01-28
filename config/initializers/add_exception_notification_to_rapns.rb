if Rails.env.production? && defined?(::ExceptionNotifier) && defined?(::Rapns)
  require 'rapns/daemon/logger'
  Rapns::Daemon::Logger.class_eval do
    def error_with_exception_notification(msg, options = {})
      error_without_exception_notification(msg, options)
      ExceptionNotifier::Notifier.background_exception_notification(msg).deliver
    end

    alias_method_chain :error, :exception_notification
  end
end
