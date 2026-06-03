# URP (2024 Winter)

Bank-level DRAM command controller modules that track per-bank state (open/closed row) and generate command requests while enforcing timing constraints. 

- **STEP1: Basic Bank Controller (Open/Close + Command Eligibility)**
  - Tracks whether a bank is active and which row is currently open
  - Decides command eligibility for **ACT / RD / WR / PRE / REF** based on row-hit vs. bank-miss and timing readiness
  - Generates per-bank command requests in a simpler control structure (no explicit scheduler handshake)

- **STEP2: FSM-based Bank Controller (Req/Grant Handshake + Timing Counter)**
  - Implements an explicit FSM (e.g., idle, activating, active, reading, writing, precharging, refreshing) with a countdown counter to satisfy timing
  - Separates **request generation** from **grant acceptance** by interacting with a scheduler (bank-level `req_*` outputs + `gnt_*` inputs)
  - Handles row-hit access directly and bank-miss via **PRE → ACT → RD/WR** sequencing, plus refresh flow
  - Parameterized per-bank control (e.g., bank id) and supports ordering metadata (e.g., sequence number)

