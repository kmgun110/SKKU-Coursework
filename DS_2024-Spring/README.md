# Digital Systems (ICE3024, 2024 Spring) 

VHDL implementations for designing digital systems.

## HW1 — Full Adder & 4-bit Adder
Design and simulate a 1-bit full adder and a 4-bit ripple-carry adder in VHDL. The 4-bit adder is built by cascading four full adders and verified using provided testbenches. 

## HW2 — FSM Sequence Detector (1010)
Implement a sequence detector that outputs `Z=1` when the input stream contains the pattern **"1010"**. Both **Mealy** and **Moore** FSM versions are implemented with asynchronous active-low reset and synchronous state transitions on the rising clock edge. 

## HW3 — FSM Tail Light Controller
Design a Moore FSM-based tail light controller using inputs **CLK, Reset, Left, Right, Brake** and driving an **8-bit LED** output pattern. Reset is asynchronous active-low; other behaviors are synchronized to the rising edge of the clock. 

