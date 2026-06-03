# URP (2025 Fall) 

Designing & Optimizing Attention by CUDA Kernel

- **MatMul (GEMM) baseline design and optimization**
  - Designed a basic CUDA matmul kernel structure and iteratively optimized performance

- **Linear Projection design for Attention**
  - Designed the matmul-based implementation plan for linear projections (e.g., Q/K/V projections and output projection)

## Projects

- `matmul_proj/`  
nvcc -o matmul main.cu kernel.cu utils.cu -lcuda -lcublas

- `attention_proj/`  
./scripts/build_nvcc.sh
./build/attn_proj B T h dk

