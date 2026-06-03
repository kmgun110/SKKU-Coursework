def compute_gflops(M, N, K, time_in_seconds):
    """
    Compute the GFLOPS for a matrix multiplication C = A x B
    where A is M x K and B is K x N.

    Parameters:
        M (int): Number of rows in A and C
        N (int): Number of columns in B and C
        K (int): Number of columns in A and rows in B
        time_in_seconds (float): Kernel execution time in seconds

    Returns:
        float: GFLOPS (giga floating-point operations per second)
    """
    num_operations = 2 * M * N * K  # each MAC = 2 FLOPs
    gflops = num_operations / time_in_seconds / 1e12
    return gflops


# Example usage
# M = N = K = 4096
# times = {
#     "[02] cublas": 0.011747,
#     "[04] shared gpu": 0.078129,
#     "[05] 1D_blocktile": 0.024699,
#     "[06] 2D_blocktile": 0.015292,
#     "[07] 2D_blocktile transposed": 0.010841,
#     "[08] warp tiling": 0.010025,
# }

# M = N = K = 8192
# times = {
#     "[02] cublas": 0.078605,
#     "[04] shared gpu": 0.682294,
#     "[05] 1D_blocktile": 0.229898,
#     "[06] 2D_blocktile": 0.118976,
#     "[07] 2D_blocktile transposed": 0.123998,
#     "[08] warp tiling": 0.084721,
# }

M = N = K = 16384
times = {
    "[02] cublas": 0.553416,
    "[04] shared gpu": 5.297872,
    "[05] 1D_blocktile": 1.734890,
    "[06] 2D_blocktile": 1.049975,
    "[07] 2D_blocktile transposed": 0.819015,
    "[08] warp tiling":  0.795845,
}

for name, t in times.items():
    gflops = compute_gflops(M, N, K, t)
    print(f"{name:<30}: {gflops:.2f} TFLOPS")