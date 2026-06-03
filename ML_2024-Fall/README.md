# Microprocessor Laboratory (ICE3029, 2024 Fall)

Embedded system implementations and term projects, using a RA6M3 board.

## A3 — GPIO & FND (Register-based)
Implemented a 7-segment(FND) display controller using direct register access.
The program drives segment outputs and digit selection lines to display a target pattern (e.g., "1234") without relying on high-level GPIO helper APIs.

## A4 — External Interrupts (Register-based)
Built an interrupt-driven calculator using external IRQ inputs (buttons).
Specific switches increment digits on the FND, another triggers the multiplication result display, and a reset behavior is included using NVIC/ICU interrupt handling.

## A5 — Timers (AGT/GPT) & LED Sequencing
Generated periodic timing events using AGT/GPT and implemented sequential LED blinking.
A switch toggles pause/resume, and the accumulated cycle count is displayed on the FND while paused, with a stop condition after a target number of cycles.

## A6 — DC/Servo Control (Wiper Motion)
Implemented a wiper-style servo motion using timer interrupts and PWM output.
On a button press, the servo moves 0° → 180° in fixed steps at a fixed interval and returns back to 0°, while an LED indicates the active run state.

## A7 — ADC/DAC-Based Mini Car Control
Developed a mini control system combining analog sensing and actuator control.
Mapped potentiometer ADC input to servo steering angle (0–180°), implemented gradual acceleration/deceleration control for a DC motor via switches, and added a light-sensor based safety stop condition.

## A8 — UART Typing Practice
Created a UART-based typing practice program communicating with a PC terminal.
The system prints a word to the terminal, accepts user input with Enter submission and Backspace editing, tracks total/correct counts, displays counters on the FND, and supports reset via a switch.

---

## Mid-term Project — UART GUI Control System
Designed and implemented a PC-to-board control system using a custom SCI-UART message protocol (STX/ETX framing with ASCII fields).  
The RA6M3 board receives control messages from a provided PC GUI and performs peripheral actions such as GPIO/FND control, switch(interrupt) events, DC motor control, ADC monitoring, and periodic timer-based tasks.
The project also supports board-to-PC “update” messages to report current states (e.g., switch events and sensor/ADC status) through UART.

## Final Project — Elevator Control Library
Implemented a function-library style final project for an “elevator” system abstraction. 
The design separates **action functions** (e.g., running DC motor/servo/speaker) and **state functions** (e.g., stop/confirm behaviors), and includes timing/delay handling (tick and delay utilities).
Overall goal is to structure the control logic in a real-time friendly way using clear state transitions (IDLE/CONFIRM/RUN/STOP) and reusable driver-style functions. 
