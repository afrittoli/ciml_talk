#!/usr/bin/env bash

# Graphs for binary classification
echo "======> metrics_by_feature" | tee -a all.log
./metrics_by_feature.sh $@ &>> all.log
echo "======> metrics_by_sampling" | tee -a all.log
./metrics_by_sampling.sh $@ &>> all.log

# Graphs for multi-classification - all classes
echo "======> metrics_by_feature node all" | tee -a all.log
CLASS_LABEL=node_provider_all ./metrics_by_feature.sh $@ &>> all.log
echo "======> metrics_by_sampling node all" | tee -a all.log
CLASS_LABEL=node_provider_all ./metrics_by_sampling.sh $@ &>> all.log
echo "======> metrics_by_topology node all" | tee -a all.log
CLASS_LABEL=node_provider_all ./metrics_by_topology.sh $@ &>> all.log

# Graphs for multi-classification - reduced classes
echo "======> metrics_by_feature node" | tee -a all.log
CLASS_LABEL=node_provider ./metrics_by_feature.sh $@ &>> all.log
echo "======> metrics_by_sampling node" | tee -a all.log
CLASS_LABEL=node_provider ./metrics_by_sampling.sh $@ &>> all.log
echo "======> metrics_by_topology node" | tee -a all.log
CLASS_LABEL=node_provider ./metrics_by_topology.sh $@ &>> all.log

# Graphs for multi-classification comparison
echo "======> metrics_by_feature_and_label" | tee -a all.log
./metrics_by_feature_and_label.sh $@ &>> all.log
echo "======> metrics_by_sampling_and_label" | tee -a all.log
./metrics_by_sampling_and_label.sh $@ &>> all.log

# Graphs for EPOCHS
echo "======> metrics_by_epochs and topology" | tee -a all.log
./metrics_by_epochs_and_topology.sh $@ &>> all.log
