# Design-and-Verification-of-APB-Protocol-using-UVM
APB Protocol is designed and verified using System Verilog based UVM. The tool used in designing and simulation is EDA Playground.

The Advanced Peripheral Bus (APB) is part of the Advanced Microcontroller Bus Architecture (AMBA) protocol family. It defines a low-cost interface that is optimized for minimal power consumption and reduced interface complexity.The APB protocol is not pipelined, use it to connect to low-bandwidth peripherals that do not require the high performance of the AXI protocol.

The APB protocol relates a signal transition to the rising edge of the clock, to simplify the integration of APB peripherals into any design flow. Every transfer takes 
at least two cycles.
