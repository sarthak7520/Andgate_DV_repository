
class wb_monitor extends uvm_monitor;
  `uvm_component_utils(wb_monitor)

  virtual wb_if vif;
  uvm_analysis_port #(wb_transaction) ap;

  function new(string name = "monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual wb_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Virtual interface wb_vif not found in config DB")
    end
  endfunction

  task run_phase(uvm_phase phase);
    wb_transaction tr;

    if (vif == null) 
      `uvm_fatal("NULLVIF", "vif null at start of run_phase");

    forever begin
      @(posedge vif.clk);
      if (vif.wb_stb_i && vif.wb_cyc_i && vif.wb_ack_o) begin
        tr = wb_transaction::type_id::create("tr");

        tr.addr = vif.wb_addr_i;
        tr.we   = vif.wb_we_i;
        tr.sel  = vif.wb_sel_i;

        if (tr.we == 0) begin
          // WRITE transaction → capture data from master
          tr.data  = vif.wb_dat_i;
          tr.rdata = 'hx;
        end 
        else begin
          // READ transaction → capture data from DUT
          tr.data  = 'hx;
          tr.rdata = vif.wb_dat_o;
        end

        `uvm_info("WB_MON", $sformatf("addr=0x%0h we=%0b sel=0x%0h data=0x%0h rdata=0x%0h", tr.addr, tr.we, tr.sel, tr.data, tr.rdata),UVM_MEDIUM)

        ap.write(tr);
      end
    end
  endtask
endclass

// class wb_monitor extends uvm_monitor;
// `uvm_component_utils(wb_monitor)
//   virtual wb_if vif;
//    wb_transaction tr;
//   uvm_analysis_port #(wb_transaction) ap;

//   function new(string name = "monitor", uvm_component parent = null);
//     super.new(name, parent);
//     ap=new("ap", this);
//     tr =new();
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//      if (!uvm_config_db#(virtual wb_if)::get(this, "", "vif", vif)) begin
//       `uvm_fatal("NOVIF", "Virtual interface wb_vif not found in config DB")
//     end
//   endfunction

//   task run_phase(uvm_phase phase);
 
//    // wb_transaction tr;
//      if (vif == null) `uvm_fatal("NULLVIF", "vif null at start of run_phase");
//     forever begin
//       @(posedge vif.clk);
//       if (vif.wb_stb_i && vif.wb_cyc_i && vif.wb_ack_o) begin
//         tr = wb_transaction::type_id::create("tr");
//         tr.addr  = vif.wb_addr_i;
//         tr.we    = vif.wb_we_i;
//         tr.sel   = vif.wb_sel_i;
//         // if (tr.we) tr.data  = vif.wb_dat_i;
//         // else       tr.rdata = vif.wb_dat_o;
//         if (tr.we == 0 ) begin
//    tr.rdata = 'hx; // or don't assign at all for write
// end else begin
//    tr.rdata = vif.wb_rdata_0; // capture DUT read data
// end
//          `uvm_info("WB_MON",$sformatf("addr=0x%0h we=%0b sel=0x%0h data=0x%0h rdata=0x%0h",tr.addr, tr.we, tr.sel, tr.data, tr.rdata),UVM_MEDIUM)
//         ap.write(tr);
//       end
//     end
   
//   endtask
// endclass

