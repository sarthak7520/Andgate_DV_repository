========================================================================
APB UART UVM Verification Project
========================================================================

PROJECT OVERVIEW
----------------
This project implements a UVM-based verification environment for a UART
peripheral with APB interface. It includes:

- RTL design: cmsdk_apb_uart.v
- Project documents: design_doc/
- UVM environment and sequences: uvm_tb/
- Testcases: tests/
- Simulation top-level: sim/top.sv
- Regression script: sim/run.do (supports single, multiple, and full tests)

------------------------------------------------------------------------


2. Directory Structure
----------------------
project_root/
│
├─ design/                # RTL design
│   └─ cmsdk_apb_uart.v
│
├─ design_doc/            # Project-related documents (specs, notes, testplan, verification plan)
│
├─ uvm_tb/                # UVM testbench (env, sequences, package)
│   ├─ apb_uart_pkg.sv
│   ├─ interface.sv
│   ├─ apb_read_seq.sv
│   └─ apb_write_seq.sv
│
├─ tests/                 # UVM test files
│   ├─ apb_uart_test.sv
│   ├─ uart_status_read_test.sv
│   └─ (other testcases)
│
├─ sim/                   # Simulation folder
│   ├─ top.sv             # Simulation top-level
│   ├─ run.do             # Regression script
│   └─ logs/              # Simulation logs
│
========================================================================
     

REQUIREMENTS
------------
- QuestaSim / ModelSim
- UVM library
- Basic knowledge of SystemVerilog and APB/UART protocols

------------------------------------------------------------------------

COMPILATION
-----------
Compile RTL and testbench using the following commands:

vlib work
vlog ../design/cmsdk_apb_uart.v
vlog -sv ../uvm_tb/interface.sv
vlog ../uvm_tb/apb_uart_pkg.sv
vlog ../uvm_tb/apb_read_seq.sv
vlog ../uvm_tb/apb_write_seq.sv
vlog ../sim/top.sv

------------------------------------------------------------------------

RUNNING TESTS
-------------
Full Regression (all tests):
vsim -do sim/run.do

Single Test:
vsim -do "set TESTS_TO_RUN uart_status_read_test; do sim/run.do"

Multiple Tests:
vsim -do "set TESTS_TO_RUN {uart_status_read_test uart_rx_only_test uart_tx_only_test}; do sim/run.do"

- Logs are saved in sim/logs/<testname>.log
- Terminal prints summary of PASS/FAIL

------------------------------------------------------------------------

LIST OF TESTS
-------------
apb_uart_test                       : Basic UART APB functionality
apb_uart_single_byte_test           : Single byte TX/RX
apb_uart_soft_reset_test            : Soft reset behavior
uart_status_read_test               : Read and verify STATUS register
uart_rx_only_test                   : Test RX functionality only
uart_tx_only_test                   : Test TX functionality only
uart_baud_change_idle_test          : Baud rate change during idle
uart_baud_change_tx_test            : Baud rate change during TX
uart_baud_invalid_test              : Invalid baud rate configuration
uart_baud_valid_test                : Valid baud rate configuration
uart_baud_write_test                : Write baud rate register
uart_interrupt_enable_disable_test  : Interrupt enable/disable
uart_intclear_test                  : Interrupt clear test
uart_intclear_selective_test        : Selective interrupt clear
uart_rx_overrun_test                : RX overrun handling
uart_rx_overrun_int_test            : RX overrun with interrupt
uart_tx_overrun_test                : TX overrun handling
uart_illegal_fsm_test               : Illegal FSM transitions
uart_hs_test_mode_test              : High-speed test mode
uart_rx_read_buffer_test            : RX buffer read behavior
uart_rxint_trigger_test             : RX interrupt trigger
uart_txint_trigger_test             : TX interrupt trigger

------------------------------------------------------------------------
TEST RESULT MEANING
-------------------
- PASS  : The simulation for this test ran successfully without errors. 
          It does NOT necessarily indicate that the DUT behavior is correct; 
          it only confirms that the testbench executed successfully.

- FAIL  : The simulation for this test encountered an error and did not complete. 
          This may be due to compilation issues, runtime errors in the testbench, 
          or other simulation failures.


NOTES
-----
- Ensure RTL and TB files are compiled in correct order.
- Make sure clock and reset are properly connected in top.sv.
- Regression script supports override via TESTS_TO_RUN variable.

------------------------------------------------------------------------

KNOWN ISSUES
------------
- In the current testbench, while reading wrong data is getting sampled, 
  please take care of that issue in future

- This behavior can cause data mismatches during verification.  

- Users should ensure sequences access only valid UART registers 
  (such as ADDR_CTRL, ADDR_STATUS, ADDR_BAUD) to avoid incorrect sampling.  

- Future improvements could include adding address validation in sequences 
  or monitors to prevent sampling data from invalid addresses.

------------------------------------------------------------------------

AUTHOR
------
RAJU GUPTA

DATE
----
01-08-2025

========================================================================
