class uart_driver extends uvm_driver#(uart_item);
  `uvm_component_utils(uart_driver)
  virtual uart_if vif;
  uvm_analysis_port#(uart_item) rx_exp_ap; // what we inject on RXD
  function new(string name, uvm_component parent);
   super.new(name,parent);
    rx_exp_ap=new("rx_exp_ap",this);
  endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF","uart_if not set")
  endfunction

  task wait_ticks(int n);
    int k;
    for(k=0;k<n;k++) @(posedge vif.BAUDTICK);
  endtask

  task drive_byte(bit [7:0] b);
    int i;
    @(posedge vif.BAUDTICK); // align
    // start bit
    vif.RXD <= 1'b0; 
    wait_ticks(16);
    // data bits LSB-first
    for(i=0;i<8;i++) 
    begin
     vif.RXD <= b[i];
      wait_ticks(16);
    end
    // stop bit
    vif.RXD <= 1'b1;
     wait_ticks(16);
  endtask

  task run_phase(uvm_phase phase);
    uart_item it;
    vif.RXD <= 1'b1; // idle high
    @(posedge vif.PRESETn);
    forever begin
      seq_item_port.get_next_item(it);
      drive_byte(it.data);
      rx_exp_ap.write(it);
      seq_item_port.item_done();
    end
  endtask
endclass

