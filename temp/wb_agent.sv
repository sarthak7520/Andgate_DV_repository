class wb_agent extends uvm_agent;
`uvm_component_utils(wb_agent)
  wb_driver    drv;
  wb_monitor   mon;
  wishbone_sequencer seqr;
  //virtual wb_if vif;

  function new(string name = "wb_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
  super.build_phase(phase);
 
    //if (is_active == UVM_ACTIVE) begin
      seqr = wishbone_sequencer::type_id::create("seqr", this);
      drv  = wb_driver::type_id::create("drv", this);
    
       mon = wb_monitor::type_id::create("mon", this);
    $display("wb_agent::: i am build_phase agent");
  endfunction

  function  void connect_phase(uvm_phase phase);
              // super.connect_phase(phase);
    //if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
  
    //end
  endfunction
endclass

