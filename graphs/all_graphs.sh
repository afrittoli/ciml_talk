#!/usr/bin/env bash

# Graphs for binary classification
./metrics_by_feature.sh $@
./metrics_by_sampling.sh $@

# Graphs for multi-classification - all classes
CLASS_LABEL=node_provider_all ./metrics_by_feature.sh $@
CLASS_LABEL=node_provider_all ./metrics_by_sampling.sh $@
CLASS_LABEL=node_provider_all ./metrics_by_topology.sh $@

# Graphs for multi-classification - reduced classes
CLASS_LABEL=node_provider ./metrics_by_feature.sh $@
CLASS_LABEL=node_provider ./metrics_by_sampling.sh $@
CLASS_LABEL=node_provider ./metrics_by_topology.sh $@

# Graphs for multi-classification comparison
./metrics_by_feature_and_label.sh $@
./metrics_by_sampling_and_label.sh $@

# Graphs for EPOCHS and other datasets comparison
# TBD
