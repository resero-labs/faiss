FROM nvidia/cuda:8.0-devel-ubuntu16.04 as builder
MAINTAINER Pierre Letessier <pletessier@ina.fr>

ADD install-mkl.sh /

RUN apt-get update -y; \
    apt-get install -y \
        build-essential \
        git \
        libgomp1 \
        libopenblas-dev \
        python3 \
        python3-dev \
        python3-pip \
        swig \
        wget \
    ; \
    /install-mkl.sh; \
    apt-get clean; \
    rm -rf /var/tmp/* /tmp/* /var/lib/apt/lists/*; \
    pip3 install \
        numpy \
        matplotlib \
    ;

WORKDIR /opt/faiss

ENV BLASLDFLAGS /usr/lib/libopenblas.so.0

COPY . /opt/faiss
COPY example_makefiles/makefile.inc.docker ./makefile.inc

RUN make; \
    make py

FROM alpine

RUN mkdir -p /artifacts
COPY --from="builder" /opt/faiss/libfaiss.a /artifacts/
COPY --from="builder" /opt/faiss/python/dist/faiss-0.1-py3-none-any.whl /artifacts/
COPY --from="builder" /install-mkl.sh /artifacts/
