#!/bin/bash

# Setup/refresh all datasets required for various experiments
# It requires CIML to be installed, and aws profile "ibmcloud"
# to be defined.
# It assumes enough examples are cached already

# Call with --force to force recreating datasets

DATA_PATH=${DATA_PATH:-/git/github.com/mtreinish/ciml/data}
TARGET_DATA_PATH=${TARGET_DATA_PATH:-/git/github.com/mtreinish/ciml/data}
SLICE=${SLICE:-":2000"}
S3_AUTH_URL=${S3_AUTH_URL:-https://s3.eu-geo.objectstorage.softlayer.net}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}


function create_datasets() {
  for feature_regex in ${FEATURES}; do
    for sampling in ${SAMPLINGS}; do
      for class_label in ${CLASS_LABELS}; do
        for build_name in ${BUILD_NAMES}; do
          DATASET=$(echo $feature_regex | tr "|" "_" | sed -e "s/(//g" -e "s/)//g")-${sampling}-${class_label}
          if [[ "$build_name" == "tempest-full-py3" ]]; then
            DATASET="${DATASET}-py3"
          fi
          echo "=== Setting up dataset $DATASET"
            # Build the dataset
            ciml-build-dataset --dataset $DATASET \
              --build-name $build_name \
              --slicer $SLICE \
              --sample-interval "$sampling" \
              --features-regex "$FEATURES" \
              --class-label $class_label \
              --tdt-split 7 0 3 \
              --data-path $DATA_PATH \
              --target-data-path $TARGET_DATA_PATH \
              --s3-url $S3_AUTH_URL $@
        done
      done
    done
  done
}

# Dataset by feature/label
FEATURES="(usr|used|1m) (usr|1m) (usr|used) (usr) (used) (1m)"
CLASS_LABELS="node_provider_all node_provider"
SAMPLINGS="1min"
BUILD_NAMES="tempest-full tempest-full-py3"
create_datasets

# Dataset by sampling/label
FEATURES="(usr|1m)"
CLASS_LABELS="node_provider_all node_provider"
SAMPLINGS="1s 10s 30s 1min 5min 10min"
BUILD_NAMES="tempest-full tempest-full-py3"
create_datasets
