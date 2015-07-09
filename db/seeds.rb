# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'yaml'
apns_config = YAML.load_file(File.expand_path('config/apns_settings.yml', Rails.root))[Rails.env]
if apns_config
  apns_config.each do |app_config|
    environment = app_config["environment"] || (Rails.env.development? ? 'development' : 'production')
    app = Rpush::Apns::App.where(:name => app_config['name'], :environment => environment).first_or_initialize
    app.certificate = File.read(File.expand_path("config/#{app_config["certificate"]}", Rails.root))
    app.password = app_config["password"]
    app.connections = app_config["connections"]
    app.save!
  end
end
