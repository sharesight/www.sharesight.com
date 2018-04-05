#!/bin/sh
set -e
. ${TRAVIS_BUILD_DIR}/bin/travis/helpers.sh # source helpers for functions

get_cache_from_s3() {
  fold_start s3.get "get cache from s3"
    cd $TRAVIS_BUILD_DIR
    BUILT_FROM_BUNDLE=false

    if [ "$AWS_ACCESS_KEY_ID" ] && [ "$AWS_SECRET_ACCESS_KEY" ]; then
      # download the current build file
      # use sync instead of mv/cp as it doesn't require the file to exist (see include/exclude)
      announce_time_start # Must use for complicated functions like this
        echo "aws s3 sync – looking for $TAR_FILENAME"
        aws s3 sync "s3://$BUCKET_NAME/www" $TRAVIS_BUILD_DIR --exclude "*" --include "$TAR_FILENAME"
      announce_time_finish

      if [ -f "./$TAR_FILENAME" ]; then
        announce tar -xf ./$TAR_FILENAME
        echo "Using bundle from S3 – s3://$BUCKET_NAME/www/$TAR_FILENAME"
        BUILT_FROM_BUNDLE=true
      else
        echo "Could not find an S3 build, will build."
      fi
    else
      echo "WARNING: Did not have access to Travis Encrypted ENV Variables!"
    fi

    export BUILT_FROM_BUNDLE
  fold_end s3.get
}

send_cache_to_s3() {
  fold_start s3.send "send cache to s3"
    if [ "$BUILT_FROM_BUNDLE" != "true" ]; then
      cd $TRAVIS_BUILD_DIR

      announce_time_start # Must use for complicated functions like this
        echo "tar -czv ./$TAR_FILENAME …"
        tar -czf ./$TAR_FILENAME ./build $( find ./data -name "*.yaml" )
      announce_time_finish

      announce aws s3 mv ./$TAR_FILENAME "s3://$BUCKET_NAME/www/$TAR_FILENAME"
      echo "Saved cache to S3 – s3://$BUCKET_NAME/www/$TAR_FILENAME"
    else
      echo "No need to save cache to S3, loaded from a build."
    fi
  fold_end s3.send
}
