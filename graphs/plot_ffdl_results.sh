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

# Load all experiments in a declarative array
declare -A FFDL_EXPERIMENTS
for experiment in $(cat $EXPERIMENTS_LOG); do
  dataset=$(echo $experiment | cut -d';' -f2)
  experiment=$(echo $experiment | cut -d';' -f3)
  FFDL_EXPERIMENTS[$dataset,$experiment]=$(echo $experiment | cut -d';' -f4)
done

# Plot by feature
FEATURES="(usr|used|1m) (usr|1m) (usr|used) (usr) (used) (1m)"
CLASS_LABELS="node_provider"
SAMPLINGS="1min"
BUILD_NAMES="tempest-full"
EPOCHS="500"
unset NETWORK_NAMES
declare -A NETWORK_NAMES
NETWORK_NAMES["100/100/100/100/100"]=dnn-5x100

DAL_PARAMS=""
# Do the data building and plotting
for feature_regex in ${FEATURES}; do
  DATASET=$(echo $feature_regex | tr "|" "_" | sed -e "s/(//g" -e "s/)//g")-${SAMPLING}-${CLASS_LABEL}
  LABEL=$(echo $feature_regex | tr "|" "/" | sed -e "s/(//g" -e "s/)//g")
  EXPERIMENT=${NETWORK_NAME}-${EPOCHS}epochs-bs${BATCH}
  DAL_PARAMS="$DAL_PARAMS --dataset-experiment-label $DATASET $EXPERIMENT $LABEL"
done
ciml-plot-data $DAL_PARAMS -k accuracy \
  --output accuracy_by_feature-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "(1 - Accuracy) with different features"
ciml-plot-data $DAL_PARAMS -k loss \
  --output loss_by_feature-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "Loss with different features"
ciml-plot-data $DAL_PARAMS -k average_loss \
  --output avg_loss_by_feature-${CLASS_LABEL}${FILENAME_SUFFIX}.png \
  --title "Average Loss with different features"


# Plot by feature and label
FEATURES="(usr|used|1m) (usr|1m) (usr|used) (usr) (used) (1m)"
CLASS_LABELS="node_provider_all node_provider"
SAMPLINGS="1min"
BUILD_NAMES="tempest-full"
EPOCHS="500"
unset NETWORK_NAMES
declare -A NETWORK_NAMES
NETWORK_NAMES["100/100/100/100/100"]=dnn-5x100


# Plot by sampling
FEATURES="(usr|1m)"
CLASS_LABELS="node_provider"
SAMPLINGS="1s 10s 30s 1min 5min 10min"
BUILD_NAMES="tempest-full"
EPOCHS="500"
unset NETWORK_NAMES
declare -A NETWORK_NAMES
NETWORK_NAMES["100/100/100/100/100"]=dnn-5x100


# Plot by sampling and label
FEATURES="(usr|1m)"
CLASS_LABELS="node_provider_all node_provider"
SAMPLINGS="1s 10s 30s 1min 5min 10min"
BUILD_NAMES="tempest-full"
EPOCHS="500"
unset NETWORK_NAMES
declare -A NETWORK_NAMES
NETWORK_NAMES["100/100/100/100/100"]=dnn-5x100


# Plot by topology
FEATURES="(usr|1m)"
CLASS_LABELS="node_provider"
SAMPLINGS="1min"
BUILD_NAMES="tempest-full"
EPOCHS="500"
unset NETWORK_NAMES
declare -A NETWORK_NAMES
NETWORK_NAMES["10/10/10"]=dnn-3x10
NETWORK_NAMES["100/100/100"]=dnn-3x100
NETWORK_NAMES["100/100/100/100/100"]=dnn-5x100
NETWORK_NAMES["500/500/500/500/500"]=dnn-5x500
NETWORK_NAMES["100/100/100/100/100/100/100/100/100/100"]=dnn-10x100
NETWORK_NAMES["1000/1000/1000"]=dnn-3x1000

# Plot by epochs
FEATURES="(usr|1m)"
CLASS_LABELS="node_provider"
SAMPLINGS="1min"
BUILD_NAMES="tempest-full"
EPOCHS="100 500 1000 5000"
unset NETWORK_NAMES
declare -A NETWORK_NAMES
NETWORK_NAMES["100/100/100/100/100"]=dnn-5x100


# Plot by epochs and topology
FEATURES="(usr|1m)"
CLASS_LABELS="node_provider"
SAMPLINGS="1min"
BUILD_NAMES="tempest-full"
EPOCHS="500 5000"
unset NETWORK_NAMES
declare -A NETWORK_NAMES
NETWORK_NAMES["10/10/10"]=dnn-3x10
NETWORK_NAMES["100/100/100"]=dnn-3x100
NETWORK_NAMES["100/100/100/100/100"]=dnn-5x100
NETWORK_NAMES["500/500/500/500/500"]=dnn-5x500
NETWORK_NAMES["100/100/100/100/100/100/100/100/100/100"]=dnn-10x100
NETWORK_NAMES["1000/1000/1000"]=dnn-3x1000
