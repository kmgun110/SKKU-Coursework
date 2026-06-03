# Algorithms (SWE2016, 2025 Fall)

C++ codes for designing algorithms.

## Assignment #2 — Custom Sorting
Implemented a high-performance sorting algorithm for large-scale 32-bit integer data (N up to 100,000,000) under strict constraints:
no global variables, no extra headers, and no built-in sorting functions (e.g., `std::sort`). The program reads a binary-formatted input file and outputs a validation result (OKAY/WRONG) along with runtime. 

## Assignment #3 
- **MST**: Compute the total cost of a minimum spanning tree for a weighted undirected graph (supports negative weights). 
- **Jump**: Find a shortest path over stepstones with bounded coordinate jumps (|dx|≤2, |dy|≤2), minimizing total Euclidean distance to reach `y ≥ G` (output rounded).   
- **Critical Time**: Given task durations and dependency edges, compute the earliest completion time with unlimited parallelism (or output -1 if impossible due to cycles). 
- **Return**: On a grid height map with movement constraints and height-based travel cost, compute the maximum reachable height within a round-trip cost budget. 
- **Stopover**: Find a valid path from vertex 1 to N that must visit K specified stopover vertices in a weighted geometric graph; aims to minimize path length while ensuring correctness. 
