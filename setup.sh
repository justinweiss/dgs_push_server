#!/bin/sh
CURRENTDIR=$PWD/`dirname $0`
test ! -f $CURRENTDIR/config/database.yml && cp $CURRENTDIR/config/database.yml.example $CURRENTDIR/config/database.yml
test ! -f $CURRENTDIR/config/initializers/secret_token.rb && SECRET_TOKEN=`rake secret` erb $CURRENTDIR/config/initializers/secret_token.rb.erb > $CURRENTDIR/config/initializers/secret_token.rb
