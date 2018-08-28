# Build an s3 backed dataset
ciml-build-dataset --dataset cpu-load-1min-dataset \
  --build-name tempest-full \
  --slicer :2000 \
  --sample-interval 10min \
  --features-regex "(usr|1min)" \
  --class-label status \
  --tdt-split 7 0 3 \
  --data-path s3://cimlrawdata \
  --target-data-path s3://cimldatasets
