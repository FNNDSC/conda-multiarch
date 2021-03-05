# nothing to see here yet.

PYTHON_VERSION=3.8
TENSORFLOW_VERSION=1.15.3

TF_MANIFEST_LIST=fnndsc/tensorflow:$(TENSORFLOW_VERSION)

tensorflow: $(TF_MANIFEST_LIST)

$(TF_MANIFEST_LIST):
	docker manifest create $@                       \
		tensorflow/tensorflow:$(TENSORFLOW_VERSION) \
		ibmcom/tensorflow-ppc64le:$(TENSORFLOW_VERSION)
	docker manifest push $@

clean:
	docker manifest rm $(TF_MANIFEST_LIST)

.PHONY: tensorflow $(TF_MANIFEST_LIST)
