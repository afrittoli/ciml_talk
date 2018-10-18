#!/bin/bash

# Run combinations of datasets and experiments via FfDL.
# Datasets are defined in CIML_DATASETS
# Experiments are defined in CIML_EXPERIMENTS

# All jobs are scheduled immediately, and run eventually
# by the cluster as soon as there is enough capacity avaialble.

# Environment variables for the ffdl client should be setup.
# Environment variables for the aws s3 client should be setup.

TARGET_DATA_PATH=${TARGET_DATA_PATH:-/git/github.com/mtreinish/ciml/data}
S3_AUTH_URL=${S3_AUTH_URL:-https://s3.eu-geo.objectstorage.softlayer.net}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-}
DATASETS=${CIML_DATASETS:-}
EXPERIMENTS=${CIML_EXPERIMENTS:-}
CIML_FFDL=${CIML_FFDL:-/git/github.com/mtreinish/ciml/ffdl_train.sh}
EXPERIMENTS_LOG=${EXPERIMENTS_LOG:-"ffdl_experiments.csv"}

declare -A FFDL_EXPERIMENTS

# Schedule all the experiments in FfDL
for dataset in $DATASETS; do
  for experiment in $EXPERIMENTS; do
    model_id=$($CIML_FFDL $dataset $experiment | awk '/Model ID/{ print $3 }')
    FFDL_EXPERIMENTS[$model_id]="$dataset,$experiment"
    echo "$(date +\"%F %R\");$dataset;$experiment;$model_id" > $EXPERIMENTS_LOG
  done
done

# Wait until experiments are complete
while [[ ${#MYMAP[@]} != 0 ]]; do
  for model_id in ${!FFDL_EXPERIMENTS[@]}; do
    model_json=$(ffdl show $model_id --json | egrep -v '^Getting model')
    # If the model json is not JSON, the API call failed
    echo $model_json | jq &> /dev/null || continue
    job_status = $(echo $model_json | jq .Payload.training.training_status.status)
    if [[ "$job_status" == "FAILED" ]]; then
      echo "$model_id FAILED"
      unset FFDL_EXPERIMENTS[$model_id]
    elif [[ "$job_status" == "COMPLETED" ]]; then
      echo "$model_id COMPLETED"
      unset FFDL_EXPERIMENTS[$model_id]
    fi
  done
  # Wait a minute before next loop
  sleep 60
done
