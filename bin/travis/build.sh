#!/bin/sh
. ${TRAVIS_BUILD_DIR}/bin/travis/helpers.sh # source helpers for functions

if [ "$BUILT_FROM_BUNDLE" = "true" ]; then
  exit 0
fi

##########
fold_start middleman.contentful "middleman contentful"
announce bundle exec middleman contentful
fold_end middleman.contentful

##########
fold_start middleman.build "middleman build"
announce bundle exec middleman build --verbose
fold_end middleman.build
