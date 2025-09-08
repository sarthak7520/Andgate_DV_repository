//------------------------------------------------------------
// uart_status_read_test.sv
//------------------------------------------------------------
/*`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

class uart_status_read_test extends uvm_test;
  `uvm_component_utils(uart_status_read_test)

  apb_uart_env env;
  apb_read_seq r_seq;

  function new(string name = "uart_status_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create environment
    env = apb_uart_env::type_id::create("env", this);

    // Create APB read sequence
    r_seq = apb_read_seq::type_id::create("r_seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("UART_STATUS", "Running UART Status Read Test", UVM_LOW)

    // Read STATUS register
    r_seq.addr = ADDR_STATUS;
    r_seq.start(env.apb_ag.m_sequencer);

    `uvm_info("UART_STATUS", $sformatf("Read STATUS value: 0x%0h", r_seq.rdata), UVM_LOW)

    phase.drop_objection(this);
  endtask
endclass*/
//------------------------------------------------------------
// uart_status_read_test.sv
//------------------------------------------------------------
`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"

class uart_status_read_test extends uvm_test;
  `uvm_component_utils(uart_status_read_test)

  apb_uart_env env;
  apb_read_seq r_seq;
  apb_item req;
  function new(string name = "uart_status_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create environment
    env = apb_uart_env::type_id::create("env", this);

    // Create APB read sequence
    r_seq = apb_read_seq::type_id::create("r_seq");
        req = apb_item::type_id::create("req");

  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("UART_STATUS", "Running UART Status Read Test", UVM_LOW)

    // Create sequence item
    
    req.addr = ADDR_STATUS;

    // Start sequence and pass the item
    r_seq.start(env.apb_ag.m_sequencer);

    // Log the read data from the item
    `uvm_info("UART_STATUS", $sformatf("Read STATUS value: 0x%0h", req.rdata), UVM_LOW)

    phase.drop_objection(this);
  endtask
endclass

