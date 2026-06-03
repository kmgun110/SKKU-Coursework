# Logic Design Laboratory (ICE2005, 2024 Winter)

Verilog implementations for Logic Circuit, covering combinational logic, sequential circuits, FSM designs, and RTL accelerator.

## W2 — XNOR Gate (Behavioral / Dataflow / Gate-Level)
Implemented an XNOR gate using three modeling styles (behavioral, dataflow, and gate-level).

## W3 — Adders (1-bit Full Adder → 4-bit Adder)
Implemented a 1-bit Full Adder using logic gates (AND/OR/NOT/XOR) and modeled it in dataflow and gate-level forms.
Then built a 4-bit adder by cascading 1-bit full adders.

## W4 — MUX / DEMUX (Behavioral / Dataflow / Gate-Level)
Designed multiplexers and demultiplexers (e.g., 4:1 MUX and 1:4 DEMUX).
Implemented them in behavioral, dataflow, and gate-level models.

## W5 — Encoder / Decoder / Priority Encoder
Implemented an encoder/decoder set (4-to-2 encoder, 2-to-4 decoder) and extended it to a 4-to-2 priority encoder with defined input priority. 

## W6 — Latches (SR Latch → Enable D Latch)
Implemented latch circuits by studying SR latch behavior and enable-gated operation.
Designed an Enable D Latch in multiple styles (behavioral, dataflow, gate-level, and structural). 

## W7 — Flip-Flops (JK FF / T FF)
Implemented JK and T flip-flops based on SR/D flip-flop concepts.
Created both behavioral and structural versions (structural built from previously designed components).

## W8 — Registers (1-bit Register → 8-bit Register / 8-bit Shift Register)
Implemented a 1-bit register and then constructed an 8-bit register and an 8-bit shift register as structural modules by instantiating 1-bit registers. 

## W9 — Counters (Ripple Counter / Ring Counter)
Implemented a ripple counter and a ring counter as structural designs using JK and D flip-flops.
Confirmed correct counting sequence, reset/preset initialization, and shifting/rotation patterns.

## W10 — FSM Design (3-bit Up/Down Counter: Moore & Mealy)
Implemented a 3-bit up/down counter using both Moore and Mealy finite state machine designs.
Verified state transitions and outputs under reset and mode control, and observed the output behavior differences between Moore and Mealy models. 

## Final Term Project — 2D Convolution RTL Accelerator
- **Controller (FSM)**: A Moore-style controller that manages the overall flow of the system (initialization → memory load → computation → display). State transitions occur on the clock rising edge and each state enables the corresponding sub-module.  
- **Memory Module**: Stores the **4×4 input** and **3×3 filter** values and also stores computation results produced by the PE / systolic array modules. 
- **Computation Module**:
  - **Single PE (Serial mode)**: Performs convolution by sequentially feeding input/filter pairs into the PE and accumulating results. The design uses a counter-based step schedule; results are saved when the counter reaches specific multiples (per convolution window) and registers are cleared for the next output.   
  - **Systolic Array (Parallel mode)**: Implements parallel convolution using multiple PEs that exchange data with neighboring PEs while computing in parallel. Implemented both **2×2** and **3×3** systolic array versions, producing a **2×2 output array**.
- **Display Module**: Converts computed results into a format suitable for FPGA **7-segment display output**, multiplexing digits and mapping values to segment patterns.
- **Top Module Integration**: Connected Controller, Memory, Computation(Serial PE / 2×2 SA / 3×3 SA), and Display modules into a full top-level design and verified end-to-end behavior. 
