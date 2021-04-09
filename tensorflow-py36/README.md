# Multi-architectural Conda Docker Image

A docker image for using tensorflow with support on IBM PowerPC `ppc64le`.

- Miniconda3 version 4.9.2
- Tensorflow version 1.15.3
- Python version 3.6.9

## Introduction

non-x86_64 Python applications are not easy to build.
Briefly, PyPi does not provide binary "wheel" packages for foreign architectures.
When you run `pip install` it will often be necessary to compile C code,
which is slow and usually fails anyways.

The challenges are discussed in more detail here:
https://github.com/FNNDSC/cookiecutter-chrisapp/wiki/Multi-Architectural-Images#python

Binaries can be obtained from repositories other than PyPi.

- Ubuntu/Debian apt package repository. However versions are often incompatible.
- Anaconda: most likely to have up to date versions and cross-platform support.
- Base docker image: can be used for one package, at the cost of a frozen Python version.

## Manual Instructions

```bash
docker manifest create fnndsc/tensorflow:1.15.3 ibmcom/tensorflow-ppc64le:1.15.3 tensorflow/tensorflow:1.15.3
docker manifest push fnndsc/tensorflow:1.15.3


docker run --rm --privileged aptman/qus -s -- -p ppc64le
docker buildx create --name moc_builder --use

docker buildx build -t fnndsc/tensorflow:1.15.3-conda4.9.2 --platform linux/amd64,linux/ppc64le --push .

docker buildx rm
docker run --rm --privileged aptman/qus -- -r
```

## Examples

### Use multi-stage build to install dependencies

```Dockerfile
FROM fnndsc/tensorflow:1.15.3-conda4.9.2 as base

FROM base as dependencies
WORKDIR /tmp

# can't use conda env export -n base -f environment.yml to create
# a lock file because the build IDs differ cross-platform
RUN conda install numpy=1.19.2 scikit-image=0.17.2 opencv=3.4.1

# remaining non-binary dependencies are safe to get from pypi because the
# difficult libraries which they depend on were installed by conda
COPY requirements.txt .
RUN pip --no-cache-dir install --upgrade-strategy only-if-needed -r requirements.txt

# install your application
WORKDIR /usr/local/src
COPY . .
RUN pip --no-cache-dir install .

# Everything is installed under /opt/conda, so we copy the directory
# back to the first stage to minimize image layers
FROM base

COPY --from=dependencies /opt/conda /opt/conda

CMD ["a_command", "--help"]
```

### Advanced Docker Build Commands

For local, single-platform build:

```
DOCKER_BUILDKIT=1 docker build -t local/pl-projectapp .
```

<details>
<summary>What's BuildKit?</summary>

BuildKit is the next-generation image builder for Docker.

https://docs.docker.com/engine/reference/builder/#buildkit

Stages are parallelized, and <code>ADD</code> downloads are
cached based on the <code>ETag</code> HTTP header.

https://github.com/moby/moby/issues/15717#issuecomment-493854811

</details>

## TODO

- [ ] GPU support
- [ ] automatic build on Github Actions
- [ ] use Tensorflow wheels from https://github.com/tensorflow/tensorflow#community-supported-builds
