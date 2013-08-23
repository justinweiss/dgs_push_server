require 'yaml'
require 'ostruct'

AppSettings = OpenStruct.new(YAML.load_file(File.expand_path('config/app_settings.yml', Rails.root))[Rails.env])
