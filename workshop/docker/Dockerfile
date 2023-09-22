FROM condaforge/mambaforge:latest as build
MAINTAINER Howard Butler <howard@hobu.co>

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

COPY environment.yml .
RUN mamba env create -f environment.yml

RUN mamba install -c conda-forge conda-pack

RUN conda-pack -n "pdal-workshop" -o /tmp/env.tar && \
  mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
  rm /tmp/env.tar

RUN /venv/bin/conda-unpack

FROM debian:bookworm-slim AS runtime

COPY --from=build /venv /venv

SHELL ["/bin/bash", "-c"]
ENTRYPOINT source /venv/bin/activate