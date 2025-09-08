class apb_monitor extends uvm_component;
  `uvm_component_utils(apb_monitor)
  virtual apb_if vif;
  uvm_analysis_port#(apb_item) ap;
  function new(string name, uvm_component parent); 
  super.new(name,parent); 
  ap=new("ap",this);
  endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF","apb_if not set")
  endfunction
  task run_phase(uvm_phase phase);
    apb_item tr;
                   $display("******************ENTERED INTO MONITOR befoer forever*********");

    forever begin
             //  $display("******************ENTERED INTO MONITOR:AFTER*************************");

      @(posedge vif.PCLK);
      if(vif.PSEL && vif.PENABLE && vif.PREADY) begin
        tr = apb_item::type_id::create("tr", this);
        tr.write = vif.PWRITE;
        tr.addr  = vif.PADDR;
        tr.wdata = vif.PWDATA;
        tr.rdata = vif.PRDATA;
         $display("******************ENTERED INTO MONITOR*************************");
         $display("WRITE =%0d, ADDR = %0d, WDATA= %0d, RDATA= %0d",tr.write,tr.addr,tr.wdata,tr.rdata);
        ap.write(tr);
        $display("******************ENTERED INTO MONITOR: AFTER WRITE(TR)*************************");
        $display("WRITE =%0d, ADDR = %0d, WDATA= %0d, RDATA= %0d",tr.write,tr.addr,tr.wdata,tr.rdata);
      end
           //   $display("AFTER END :WRITE =%0d, ADDR = %0d, WDATA= %0d, RDATA= %0d",tr.write,tr.addr,tr.wdata,tr.rdata);

    end
  endtask
endclass
