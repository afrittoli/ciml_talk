#!/bin/bash

# Plot the results of the experiments
TARGET_DATA_PATH=${TARGET_DATA_PATH:-/git/github.com/mtreinish/ciml/data}
S3_AUTH_URL=${S3_AUTH_URL:-https://s3.eu-geo.objectstorage.softlayer.net}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}
DATASETS=${CIML_DATASETS:-}
EXPERIMENTS=${CIML_EXPERIMENTS:-}
CIML_FFDL=${CIML_FFDL:-/git/github.com/mtreinish/ciml/ffdl_train.sh}
EXPERIMENTS_LOG=${EXPERIMENTS_LOG:-"ffdl_experiments.csv"}
FILENAME_SUFFIX=${FILENAME_SUFFIX:-""}

# Load all experiments in a declarative array
declare -A FFDL_EXPERIMENTS
for experiment in $(cat $EXPERIMENTS_LOG); do
  dataset=$(echo $experiment | cut -d';' -f2)
  experiment=$(echo $experiment | cut -d';' -f3)
  FFDL_EXPERIMENTS[$dataset,$experiment]=$(echo $experiment | cut -d';' -f4)
done

# Plot by sampling
FEATURES="(usr|1m)"
CLASS_LABEL=${CLASS_LABEL:-status}
SAMPLINGS="10s 30s 1min 5min 10min"
BUILD_NAMES="tempest-full"
EPOCHS="500"
NETWORK=${NETWORK:-100/100/100/100/100}
NETWORK_NAME=${NETWORK_NAME:-"dnn-100x5"}
BATCH=128

DAL_PARAMS=""
# Do the data building and plotting
for sampling in ${SAMPLINGS}; do
  DATASET=$(echo $FEATURES | tr "|" "_" | sed -e "s/(//g" -e "s/)//g")-${sampling}-${CLASS_LABEL}
  LABEL=$sampling
  EXPERIMENT=${NETWORK_NAME}-${EPOCHS}epochs-bs${BATCH}
  MODEL_ID=${FFDL_EXPERIMENTS[$DATASET,$EXPERIMENT]}
  DAL_PARAMS="$DAL_PARAMS --dataset-experiment-label \"$MODEL_ID/$DATASET\" $EXPERIMENT $LABEL"
done
ciml-plot-data $DAL_PARAMS -k accuracy \
  --output accuracy_by_sampling-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "(1 - Accuracy) with different resolution"
ciml-plot-data $DAL_PARAMS -k loss \
  --output loss_by_sampling-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "Loss with different resolution"
ciml-plot-data $DAL_PARAMS -k average_loss \
  --output avg_loss_by_sampling-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "Average Loss with different resolution"
