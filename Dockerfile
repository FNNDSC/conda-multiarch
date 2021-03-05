FROM fnndsc/tensorflow:1.15.3 as base

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/conda/bin:$PATH
ENV PYTHONPATH=/opt/conda/lib/python3.6/site-packages:/usr/local/lib/python3.6/dist-packages

FROM base as installer
WORKDIR /tmp

# download conda installer
RUN apt-get update
RUN apt-get install -y curl
RUN curl -so install-conda.sh \
    https://repo.anaconda.com/miniconda/Miniconda3-py38_4.9.2-$(uname -s)-$(uname -m).sh
# install conda
RUN bash install-conda.sh -b -p /opt/conda

# downgrade python to the same version which was present in base image
RUN conda install python=$(/usr/local/bin/python --version | awk '{print $2}')


FROM base

COPY --from=installer /opt/conda /opt/conda
