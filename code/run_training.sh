# Train the model based on the dataset and experiment
# Store the evaluation metrics as a JSON file
ciml-train-model --dataset cpu-load-1min-dataset \
  --experiment dnn-5x100 \
  --data-path s3://cimldatasets
