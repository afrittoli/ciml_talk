# Define a local experiment
ciml-setup-experiment --experiment dnn-5x100 \
  --estimator tf.estimator.DNNClassifier \
  --hidden-layers 100/100/100/100/100 \
  --steps $(( 2000 / 128 * 500 )) \
  --batch-size 128 \
  --epochs 500 \
  --data-path s3://cimldatasets
