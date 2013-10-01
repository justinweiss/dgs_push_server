# The Dragon Go Client Push Server

[![Build Status](https://travis-ci.org/justinweiss/dgs_push_server.png?branch=master)](https://travis-ci.org/justinweiss/dgs_push_server) [![Code Climate](https://codeclimate.com/github/justinweiss/dgs_push_server.png)](https://codeclimate.com/github/justinweiss/dgs_push_server)

This server handles push notifications for
[Dragon Go Client](http://dgs.uberweiss.net) for iOS devices.

## Installation

After checking out the repository, run `bundle install`, then
`setup.sh`. This will generate a new secret token and copy a bunch of
example config files to the correct config filenames.

You'll probably want to go through all of the `.yml` files in the
`config/` directory and tweak them to fit your configuration. You'll
also need some APNS certificates, which should be converted to
`.pems`, referenced in `apns_settings.yml`, and dropped in the
`config/` directory.

Next, you should run `rake db:seed` to get the certificates added to
your database.

Finally, you'll want to run `foreman start`. This will run the rails
push server, the APNS pusher, sidekiq, and a sidekiq scheduler. Once
all these parts are running, if your certs are correct and your build
of Dragon Go Client is pointing to the right place, you should be able
to receive push notifications!
