#!/bin/sh
CURRENTDIR=$PWD/`dirname $0`
test ! -f $CURRENTDIR/config/initializers/secret_token.rb && SECRET_TOKEN=`rake secret` erb $CURRENTDIR/config/initializers/secret_token.rb.erb > $CURRENTDIR/config/initializers/secret_token.rb

for config_file in app_settings.yml database.yml apns_settings.yml smtp_settings.yml exception_notifier_settings.yml; do
    test ! -f $CURRENTDIR/config/$config_file && cp $CURRENTDIR/config/$config_file.example $CURRENTDIR/config/$config_file
done
