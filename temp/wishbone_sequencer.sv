`ifndef WISHBONE_SEQUENCER_SV
`define WISHBONE_SEQUENCER_SV

class wishbone_sequencer extends uvm_sequencer #(wb_transaction);
  `uvm_component_utils(wishbone_sequencer)

  function new(string name = "wishbone_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     $display("__________i am in sequencer");
  endfunction

endclass

`endif

