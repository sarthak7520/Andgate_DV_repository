class wb_driver extends uvm_driver #(wb_transaction);
`uvm_component_utils(wb_driver)
  virtual wb_if vif;

  function new(string name = "wb_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     if (!uvm_config_db#(virtual wb_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Virtual interface wb_vif not found in config DB")
    end
  endfunction

  task run_phase(uvm_phase phase);
  wb_transaction tr;
  forever begin
    seq_item_port.get_next_item(tr);
    drive_wishbone(tr);
    $display("___________driver run phase__________");
    seq_item_port.item_done();  // <-- only here
  end
endtask

task drive_wishbone(wb_transaction tr);
  if (tr.we) begin
    // WRITE
    vif.wb_addr_i <= tr.addr;
    vif.wb_dat_i  <= tr.data;
    vif.wb_we_i   <= 1;
    vif.wb_sel_i  <= tr.sel;
    vif.wb_stb_i  <= 1;
    vif.wb_cyc_i  <= 1;
    //$display("value of addr%oh,data%h",tr.addr,tr.data);
    `uvm_info("WB_DRIVER", $sformatf(" addr=0x%0h we=%0h sel=0x%0h data=0x%0h",  vif.wb_addr_i, vif.wb_we_i, vif.wb_sel_i, vif.wb_dat_i),UVM_MEDIUM)
    @(posedge vif.clk);
    wait(vif.wb_ack_o);
  end
  else begin
    // READ
    vif.wb_addr_i <= tr.addr;
    vif.wb_we_i   <= 0;
    vif.wb_stb_i  <= 1;
    vif.wb_cyc_i  <= 1;
   // $display("value of addr%oh,data%h",tr.addr,tr.data);
    @(posedge vif.clk);
    wait(vif.wb_ack_o);
    tr.rdata = vif.wb_dat_o;   // capture DUT read data
  end

  vif.wb_stb_i <= 0;
  vif.wb_cyc_i <= 0;
  $display("driver end");
endtask
endclass

    //foreach (int i int {0:tr.burst_len-1}) begin
// for (int i = 0; i < tr.burst_len; i++) begin
//    for (int i = 0; i < 10; i++) begin
//       // vif.wb_addr_i <= tr.addr + i;
//        vif.wb_addr_i <= tr.addr ;
//       vif.wb_dat_i  <= tr.data ; // can randomize for write
//       vif.wb_we_i   <= tr.we;
//       vif.wb_sel_i  <= tr.sel;
//       vif.wb_stb_i  <= 1;
//       vif.wb_cyc_i  <= 1;
//       $display("value of addr%oh,data%h",tr.addr,tr.data);
//        `uvm_info("WB_DRIVER", $sformatf("Driving beat %0d: addr=0x%0h we=%0b sel=0x%0h data=0x%0h", i, vif.wb_addr_i, vif.wb_we_i, vif.wb_sel_i, vif.wb_dat_i),UVM_MEDIUM)
//       @(posedge vif.clk);
//       //wait(vif.wb_ack_o == 1);
//       wait(vif.wb_ack_o);
//        //if (!tr.we) tr.rdata = vif.wb_dat_o;
//         if (tr.we == 0) 
//         tr.addr <= vif.wb_addr_i;
//         tr.rdata <= vif.wb_dat_o;
      
   
//       @(negedge vif.clk);
//     end
//     end
//     vif.wb_stb_i <= 0;
//     vif.wb_cyc_i <= 0;
//    //
//     $display("driver end");
//   endtask
// endclass

