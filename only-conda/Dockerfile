# fyi, alpine doesn't work.
# install-conda.sh: line 412: /opt/conda/conda.exe: No such file or directory
FROM debian:buster as base
FROM base as installer

RUN apt-get update && apt-get install -y curl

WORKDIR /tmp

ARG CONDA_VERSION=4.9.2
ARG PYTHON_VERSION=py39

RUN curl -so install-conda.sh \
    https://repo.anaconda.com/miniconda/Miniconda3-${PYTHON_VERSION}_${CONDA_VERSION}-$(uname -s)-$(uname -m).sh
RUN bash install-conda.sh -b -p /opt/conda

FROM base
COPY --from=installer /opt/conda /opt/conda
ENV PATH=/opt/conda/bin:$PATH
