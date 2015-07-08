require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DgsPushServer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Add the fonts path
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # Precompile additional assets
    config.assets.precompile += %w( .svg .eot .woff .ttf )

    smtp_settings = YAML.load_file(File.expand_path("../smtp_settings.yml", __FILE__))[Rails.env]

    if smtp_settings
      config.action_mailer.smtp_settings = smtp_settings.symbolize_keys
    end

    exception_notifier_settings = YAML.load_file(File.expand_path("../exception_notifier_settings.yml", __FILE__))[Rails.env]

    if exception_notifier_settings
      config.middleware.use(ExceptionNotification::Rack, :email => exception_notifier_settings.symbolize_keys)
    end

    config.middleware.swap Rails::Rack::Logger, Silencer::Logger, :silence => %w(/test/succeed /test/fail)
  end
end
