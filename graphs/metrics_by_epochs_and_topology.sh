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
for exp in $(cat $EXPERIMENTS_LOG); do
  dataset=$(echo $exp | cut -d';' -f2)
  experiment=$(echo $exp | cut -d';' -f3)
  FFDL_EXPERIMENTS[$dataset,$experiment]=$(echo $exp | cut -d';' -f4)
done

# Plot by sampling
FEATURES="(usr|1m)"
CLASS_LABEL=${CLASS_LABEL:-status}
SAMPLING=1min
BUILD_NAMES="tempest-full"
EPOCHS="100 500"
BATCH=128

declare -A NETWORK_NAMES
NETWORK_NAMES["100/100/100/100/100"]=dnn-5x100
NETWORK_NAMES["500/500/500/500/500"]=dnn-5x500

DAL_PARAMS=""
# Do the data building and plotting
for network in "${!NETWORK_NAMES[@]}"; do
  for epoch in $EPOCHS; do
    DATASET=$(echo $FEATURES | tr "|" "_" | sed -e "s/(//g" -e "s/)//g")-${SAMPLING}-${CLASS_LABEL}
    LABEL=${NETWORK_NAMES[$network]}
    EXPERIMENT=${NETWORK_NAMES[$network]}-${epoch}epochs-bs${BATCH}
    MODEL_ID=${FFDL_EXPERIMENTS[$DATASET,$EXPERIMENT]}
    if [[ "$MODEL_ID" == "" ]]; then
      echo "$DATASET $EXPERIMENT" >> missing_experiments.log
    fi
    DAL_PARAMS="$DAL_PARAMS --dataset-experiment-label $MODEL_ID/data/$DATASET $EXPERIMENT $LABEL"
  done
done
ciml-plot-data $DAL_PARAMS -k accuracy \
  --output accuracy_by_epochs_topology-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "(1 - Accuracy) with different network topologies" \
  --data-path "$TARGET_DATA_PATH"
ciml-plot-data $DAL_PARAMS -k loss \
  --output loss_by_epochs_topology-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "Loss with different network topologies" \
  --data-path "$TARGET_DATA_PATH"
ciml-plot-data $DAL_PARAMS -k average_loss \
  --output avg_loss_by_epochs_topology-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "Loss with different network topologies" \
  --data-path "$TARGET_DATA_PATH"
