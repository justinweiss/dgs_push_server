# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'yaml'
apns_config = YAML.load_file(File.expand_path('config/apns_config.yml', Rails.root))[Rails.env]
if apns_config
  apns_config.each do |app_config|
    app = Rapns::Apns::App.new
    app.name = app_config["name"]
    app.certificate = File.read(File.expand_path("config/#{app_config["certificate"]}", Rails.root))
    app.environment = Rails.env
    app.password = app_config["password"]
    app.connections = app_config["connections"]
    app.save!
  end
end
