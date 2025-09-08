`include "uvm_macros.svh"
import uvm_pkg::*;
class apb_item extends uvm_sequence_item;
  rand bit        write;         // 1=write, 0=read
  rand bit [11:0]  addr;          // PADDR[11:2]
  rand bit [31:0] wdata;
       bit [31:0] rdata;
  `uvm_object_utils_begin(apb_item)
    `uvm_field_int(write, UVM_ALL_ON)
    `uvm_field_int(addr , UVM_ALL_ON)
    `uvm_field_int(wdata, UVM_ALL_ON)
    `uvm_field_int(rdata, UVM_NOPRINT)
  `uvm_object_utils_end

  function new(string name="apb_item");
   super.new(name); 
  endfunction
endclass

