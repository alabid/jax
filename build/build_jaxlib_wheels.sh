#!/bin/bash
set -xev

PYTHON_VERSIONS="3.6.8 3.7.2 3.8.0 3.9.0"
CUDA_VERSIONS="10.1 10.2 11.0 11.1 11.2"
CUDA_VARIANTS="cuda" # "cuda-included"

mkdir -p dist

# build the cuda linux packages
for CUDA_VERSION in $CUDA_VERSIONS
do
  docker build -t jaxbuild jax/build/ --build-arg JAX_CUDA_VERSION=$CUDA_VERSION
  for PYTHON_VERSION in $PYTHON_VERSIONS
  do
    for CUDA_VARIANT in $CUDA_VARIANTS
    do
      mkdir -p dist/${CUDA_VARIANT}${CUDA_VERSION//.}
      docker run -it --tmpfs /build:exec --rm -v $(pwd)/dist:/dist jaxbuild $PYTHON_VERSION $CUDA_VARIANT $CUDA_VERSION
      mv -f dist/*.whl dist/${CUDA_VARIANT}${CUDA_VERSION//.}/
    done
  done
done

# build the pypi linux packages
docker build -t jaxbuild jax/build/
for PYTHON_VERSION in $PYTHON_VERSIONS
do
  mkdir -p dist/nocuda/
  docker run -it --tmpfs /build:exec --rm -v $(pwd)/dist:/dist jaxbuild $PYTHON_VERSION nocuda
  mv -f dist/*.whl dist/nocuda/
done
