#!/bin/sh
. ${TRAVIS_BUILD_DIR}/bin/travis/helpers.sh # source helpers for functions

if [ "$RUN_TESTS" = "false" ]; then
  exit 0
fi

##########
fold_start rspec "rspec spec tests"
  announce_time_start # Must use when working with env variables.
    echo "bundle exec rspec spec"
    APP_ENV=development bundle exec rspec spec # run in development so we don't have the s3_sync stuff
  announce_time_finish

  announce bundle exec bundle-audit update
  announce bundle exec bundle-audit check
fold_end rspec
