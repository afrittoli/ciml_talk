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

declare -A FFDL_EXPERIMENTS

# Load all experiments in a declarative array
for experiment in $(cat $EXPERIMENTS_LOG); do
  dataset=$(echo $experiment | cut -d';' -f2)
  experiment=$(echo $experiment | cut -d';' -f3)
  FFDL_EXPERIMENTS[$dataset,$experiment]=$(echo $experiment | cut -d';' -f4)
done

# Plot by feature

# Plot by feature and label

# Plot by sampling

# Plot by sampling and label

# Plot by topology

# Plot by epochs

# Plot by epochs and topology
