# 32-bit-Floating-Point-ALU
A 32-bit ALU for operations on IEEE-754 Single Precision floating points. This project is being done for the individual project for EN3021 Digital Design Systems at the University of Moratuwa. This contains:
- Adder and Subtractor: Requires 3 cycles 
- Multiplier: Requires 3 cycles
- Divider: Requires 25 cycles

The design has been implemented in 4 pipelines. However, for division, the exponent results are stored in a "bench" stage until the completion of the operations on the mantissa. As different operations require different clock cycles, a reordering method is required externally to manage the operations. Error prevention for errors regarding collision of operation completions has not yet been implemented. 

Top-level entity: alu.v
![Artboard 1@4x](https://github.com/user-attachments/assets/c1aeaa73-86f8-45b7-ac42-08dffc9eff2e)
