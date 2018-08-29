#!/bin/bash

# Run the same experiment on different datasets
# for several combinations of dstat features

# It requires CIML to be installed
# It assumes enough examples are cached already

# Call with --force to force recreating datasets and experiments

NETWORK=${NETWORK:-100/100/100/100/100}
NETWORK_NAME=${NETWORK_NAME:-"dnn-100x5"}
BATCH=128
EPOCHS=${EPOCHS:-500}
DATA_PATH=${DATA_PATH:-/git/github.com/mtreinish/ciml/data}
TARGET_DATA_PATH=${TARGET_DATA_PATH:-/git/github.com/mtreinish/ciml/data}
CLASS_LABEL=${CLASS_LABEL:-status}
SLICE=${SLICE:-":2000"}
FEATURES="(usr|1m)"
FILENAME_SUFFIX=${FILENAME_SUFFIX:-""}

SAMPLINGS="10s 30s 1min 5min 10min"

for sampling in ${SAMPLINGS}; do
  DATASET=$(echo $FEATURES | tr "|" "_" | sed -e "s/(//g" -e "s/)//g")-${sampling}-${CLASS_LABEL}
  echo "=== Setting up dataset $DATASET"
  # Build the dataset
  ciml-build-dataset --dataset $DATASET \
    --build-name tempest-full \
    --slicer $SLICE \
    --sample-interval "$sampling" \
    --features-regex "$FEATURES" \
    --class-label $CLASS_LABEL \
    --tdt-split 7 0 3 \
    --data-path $DATA_PATH \
    --target-data-path $TARGET_DATA_PATH $@
  # Setup the experiment
  EXPERIMENT=${NETWORK_NAME}-${EPOCHS}epochs-bs${BATCH}
  echo "=== Setting up experiment $EXPERIMENT"
  ciml-setup-experiment --experiment $EXPERIMENT \
    --dataset $DATASET \
    --estimator tf.estimator.DNNClassifier \
    --hidden-layers $NETWORK \
    --steps $(( 2000 / BATCH * EPOCHS )) \
    --batch-size $BATCH \
    --epochs ${EPOCHS} \
    --data-path $TARGET_DATA_PATH $@
  # Do the training if this is a new experiment
  if [[ "$?" == 0 ]]; then
    echo "=== Training $EXPERIMENT against $DATASET"
    ciml-train-model --dataset $DATASET --experiment $EXPERIMENT \
      --data-path $TARGET_DATA_PATH
  fi
done

DAL_PARAMS=""
# Do the data building and plotting
for sampling in ${SAMPLINGS}; do
  DATASET=$(echo $FEATURES | tr "|" "_" | sed -e "s/(//g" -e "s/)//g")-${sampling}-${CLASS_LABEL}
  LABEL=$sampling
  EXPERIMENT=${NETWORK_NAME}-${EPOCHS}epochs-bs${BATCH}
  DAL_PARAMS="$DAL_PARAMS --dataset-experiment-label $DATASET $EXPERIMENT $LABEL"
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
