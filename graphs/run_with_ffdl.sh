#!/usr/bin/env bash

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
ONLY_WAIT=${ONLY_WAIT:-"false"}
ONLY_NEW=${ONLY_NEW:-"true"}
MAX_EXPERIMENTS=${MAX_EXPERIMENTS:-10}

declare -A FFDL_EXPERIMENTS

if [[ "$ONLY_WAIT" == "true" ]]; then
  # Load all experiments in a declarative array
  for experiment in $(cat $EXPERIMENTS_LOG); do
    dataset=$(echo $experiment | cut -d';' -f2)
    experiment=$(echo $experiment | cut -d';' -f3)
    FFDL_EXPERIMENTS[$dataset,$experiment]=$(echo $experiment | cut -d';' -f4)
  done
else
  # Schedule all the experiments in FfDL
  for dataset in $DATASETS; do
    for experiment in $EXPERIMENTS; do
      if [[ "$ONLY_NEW"  == "true" ]]; then
        is_new=$(grep "$dataset;$experiment" -c $EXPERIMENTS_LOG)
        [[ $is_new -ge 1 ]] && continue
      fi
      # Wait until one training slot becomes available
      while [[ ${#FFDL_EXPERIMENTS[@]} -gt $MAX_EXPERIMENTS ]]; do
        echo "$(date +'%F %R') Waiting for one experiment to complete..."
        for model_id in ${!FFDL_EXPERIMENTS[@]}; do
          model_json=$(ffdl show $model_id --json | egrep -v '^Getting model')
          # If the model json is not JSON, the API call failed
          echo $model_json | jq . &> /dev/null || continue
          job_status=$(echo $model_json | jq -r .Payload.training.training_status.status)
          if [[ "$job_status" == "FAILED" ]]; then
            echo "$model_id FAILED"
            unset FFDL_EXPERIMENTS[$model_id]
            # One slot free, continue and skip the wait time
            break 2
          elif [[ "$job_status" == "COMPLETED" ]]; then
            echo "$model_id COMPLETED"
            unset FFDL_EXPERIMENTS[$model_id]
            # One slot free, continue and skip the wait time
            break 2
          fi
        done
        echo "# experiments: ${#FFDL_EXPERIMENTS[@]}"
        # Wait a minute before next loop
        sleep 60
      done
      # There's a free training slot so schedule a job
      model_id=$($CIML_FFDL $dataset $experiment | awk '/Model ID/{ print $3 }')
      echo "Submit job $model_id for dataset $dataset with experiment $experiment"
      FFDL_EXPERIMENTS[$model_id]="$dataset,$experiment"
      echo "$(date +'%F %R');$dataset;$experiment;$model_id" >> $EXPERIMENTS_LOG
    done
  done
fi
