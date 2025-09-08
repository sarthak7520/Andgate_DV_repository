`include "uvm_macros.svh"
import uvm_pkg::*;


 class apb_driver extends uvm_driver#(apb_item);
  `uvm_component_utils(apb_driver)
   
  virtual apb_if vif;
  localparam int ADDR_WIDTH    = 'h12;
   function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for apb_driver")
  endfunction

  task run_phase(uvm_phase phase);
    apb_item tr;
    //int timeout_cnt;
    int unsigned timeout_cnt = 0;
    int TIMEOUT_MAX = 1000;

    // Wait for reset deassertion
    @(posedge vif.PRESETn);
    $display("[%0t] APB DRIVER: Starting after reset deassertion", $time);

    // Initialize APB bus to idle
    vif.PSEL    <= 0;
    vif.PENABLE <= 0;
    vif.PWRITE  <= 0;
    vif.PADDR   <= '0;
    vif.PWDATA  <= '0;
    @(posedge vif.PCLK);

    forever begin
      timeout_cnt = 0;

      // Get next transaction
      seq_item_port.get_next_item(tr);
      `uvm_info("APB DRIVER", $sformatf("Got transaction: ADDR=0x%0h WDATA=0x%0h WRITE=%0d",
                                   tr.addr, tr.wdata, tr.write), UVM_MEDIUM)


      // Setup phase
      @(posedge vif.PCLK);
      vif.PSEL    <= 1'b1;
      vif.PWRITE  <= tr.write;
      vif.PADDR <= tr.addr[11:2];
      @(posedge vif.PCLK);
     // vif.PADDR <= tr.addr[ADDR_WIDTH-1:0];         //jahid
      vif.PWDATA  <= tr.wdata;
      vif.PENABLE <= 1'b0;
      $display("[%0t] APB DRIVER: Setup done, waiting one clock before access", $time);

      // Access phase
      @(posedge vif.PCLK);
      vif.PENABLE <= 1'b1;
      $display("[%0t] APB DRIVER: Access phase, PSEL=%0b PENABLE=%0b", $time, vif.PSEL, vif.PENABLE);

      // Wait for PREADY 
      while (vif.PREADY !== 1'b1) begin
        @(posedge vif.PCLK);
        timeout_cnt++;
        if (timeout_cnt > TIMEOUT_MAX) begin
          `uvm_error("APB_DRIVER", $sformatf("Timeout waiting for PREADY after %0d cycles. ADDR=0x%0h, WDATA=0x%0h",
                      timeout_cnt, vif.PADDR, vif.PWDATA));
          if (!tr.write) tr.rdata = '0;
          break;
        end
      end
      $display("[%0t] APB DRIVER: PREADY seen for ADDR=0x%0h", $time, vif.PADDR);

      // Read data if read transaction
      if (!tr.write)
        tr.rdata = vif.PRDATA;
       @(posedge vif.PCLK);
        $display("RDATA = %0d ", tr.rdata);


      // Return to idle
      @(posedge vif.PCLK);
      vif.PSEL    <= 0;
      vif.PENABLE <= 0;
      vif.PWRITE  <= 0;

      seq_item_port.item_done();
      $display("[%0t] APB DRIVER: Transaction completed", $time);
    end
  endtask
endclass

