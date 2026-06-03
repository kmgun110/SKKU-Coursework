#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
mkdir -p build && cd build
nvcc ../src/main.cu ../src/kernel.cu ../src/utils.cu \
  -o attn_proj \
  -O3  \
  -I /usr/local/cuda/include \
  -L /usr/local/cuda/lib64 \
  -lcublas -lcudart
echo "build/attn_proj 빌드 완료"
