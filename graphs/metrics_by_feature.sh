#!/usr/bin/env bash

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
for exp in $(awk '{ print $2 }' $EXPERIMENTS_LOG); do
  dataset=$(echo $exp | cut -d';' -f2)
  experiment=$(echo $exp | cut -d';' -f3)
  FFDL_EXPERIMENTS[$dataset,$experiment]=$(echo $exp | cut -d';' -f4)
done

# Plot by feature
FEATURES="(usr|used|1m) (usr|1m) (usr|used) (usr) (used) (1m)"
CLASS_LABEL=${CLASS_LABEL:-status}
SAMPLING=${SAMPLING:-"1min"}
BUILD_NAMES="tempest-full"
EPOCHS="500"
NETWORK=${NETWORK:-100/100/100/100/100}
NETWORK_NAME=${NETWORK_NAME:-"dnn-5x100"}
BATCH=128

DAL_PARAMS=""
# Do the data building and plotting
for feature_regex in ${FEATURES}; do
  DATASET=$(echo $feature_regex | tr "|" "_" | sed -e "s/(//g" -e "s/)//g")-${SAMPLING}-${CLASS_LABEL}
  LABEL=$(echo $feature_regex | tr "|" "/" | sed -e "s/(//g" -e "s/)//g")
  EXPERIMENT=${NETWORK_NAME}-${EPOCHS}epochs-bs${BATCH}
  MODEL_ID=${FFDL_EXPERIMENTS[$DATASET,$EXPERIMENT]}
  if [[ "$MODEL_ID" == "" ]]; then
    echo "$DATASET $EXPERIMENT" >> missing_datasets.log
  fi
  DAL_PARAMS="$DAL_PARAMS --dataset-experiment-label $MODEL_ID/data/$DATASET $EXPERIMENT $LABEL"
done
ciml-plot-data $DAL_PARAMS -k accuracy \
  --output accuracy_by_feature-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "(1 - Accuracy) with different features" \
  --data-path "$TARGET_DATA_PATH"
ciml-plot-data $DAL_PARAMS -k loss \
  --output loss_by_feature-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "Loss with different features" \
  --data-path "$TARGET_DATA_PATH"
ciml-plot-data $DAL_PARAMS -k average_loss \
  --output avg_loss_by_feature-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "Average Loss with different features" \
  --data-path "$TARGET_DATA_PATH"
