# Generated with:

ciml-build-dataset
	--dataset viz-data \
	--build-name tempest-full \
	--sample-interval 1min \
	--features-regex '(usr|1min|read.1)' \
	--tdt-split 10 0 0 \
	--visualize \
	--slicer ':100' \
	--data-plots-folder /git/github.com/afrittoli/ciml_talk/graphs/100norm
