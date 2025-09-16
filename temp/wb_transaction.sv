`include "uvm_macros.svh"
import uvm_pkg::*;
class wb_transaction extends uvm_sequence_item;
  //rand bit [25:0]addr;
       rand  bit [39:0]addr;
         bit RESETN;
  rand bit [31:0] data;
  rand bit        we;    // 1=Write, 0=Read
  rand bit [3:0]  sel;
  rand int        burst_len;

  bit [31:0]      rdata; // For read response

  `uvm_object_utils_begin(wb_transaction)
    `uvm_field_int(addr,       UVM_ALL_ON)
    `uvm_field_int(data,       UVM_ALL_ON)
    `uvm_field_int(we,         UVM_ALL_ON)
    `uvm_field_int(sel,        UVM_ALL_ON)
    `uvm_field_int(burst_len,  UVM_ALL_ON)
    `uvm_field_int(rdata,      UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "wb_transaction");
    super.new(name);
  endfunction
endclass

