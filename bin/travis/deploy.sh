#!/bin/sh
set -e
. ${TRAVIS_BUILD_DIR}/bin/travis/helpers.sh # source helpers for functions

# NOTE: This should always be built in the deploy step, so only for develop/master branches and NOT PRs

notify_bugsnag_release() {
  RESULT=$(curl -d "apiKey=$BUGSNAG_API_KEY&releaseStage=$APP_ENV&repository=$GITHUB_REPOSITORY&branch=${TRAVIS_PULL_REQUEST_BRANCH:=TRAVIS_BRANCH}&revision=$TRAVIS_COMMIT" https://notify.bugsnag.com/deploy)
  echo "Result from notify.bugsnag.com/deploy: $RESULT"
}

##########
fold_start middleman.s3_sync "middleman s3_sync"
  announce bundle exec middleman s3_sync $FORCE
fold_end middleman.s3_sync

fold_start bugsnag.release "notify bugsnag release"
  announce notify_bugsnag_release
fold_end bugsnag.release
