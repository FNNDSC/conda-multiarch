# fyi, alpine doesn't work.
# install-conda.sh: line 412: /opt/conda/conda.exe: No such file or directory

ARG BASE=debian:buster
FROM ${BASE} as base
FROM base as installer

RUN apt-get update && apt-get install -y curl

WORKDIR /tmp

ARG CONDA_VERSION=py39_4.12.0

RUN curl -fso install-conda.sh \
    https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-$(uname -s)-$(uname -m).sh
RUN bash install-conda.sh -b -p /opt/conda

ARG PYTHON_VERSION=3.10.4
RUN /opt/conda/bin/conda install -c conda-forge -y python=${PYTHON_VERSION}

FROM base
COPY --from=installer /opt/conda /opt/conda
ENV PATH=/opt/conda/bin:$PATH
