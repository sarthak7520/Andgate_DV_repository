class uart_monitor extends uvm_component;
  `uvm_component_utils(uart_monitor)

  virtual uart_if vif;
  uvm_analysis_port#(uart_item) tx_obs_ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    tx_obs_ap = new("tx_obs_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF","uart_if not set")
  endfunction

  task run_phase(uvm_phase phase);
    uart_item it;
    int i;

    $display("MONITOR:Waiting for reset deassertion...");
    @(posedge vif.PRESETn);
    $display("MONITOR:Reset deasserted, starting monitor...");

    forever begin
      // Wait for start bit
      @(negedge vif.TXD);
      `uvm_info("UART_MON", "Detected start bit", UVM_LOW);

      // Align to middle of start bit
      repeat (8) @(posedge vif.BAUDTICK);

      // Recheck start bit still low
      if (vif.TXD != 1'b0)
        continue;

      // Now sample 8 data bits, LSB first
      it = uart_item::type_id::create("tx_obs", this);
      it.data = '0;
      for (i = 0; i < 8; i++) begin
        repeat (16) @(posedge vif.BAUDTICK);
        it.data[i] = vif.TXD;
      end

      // Stop bit (optional check)
      repeat (16) @(posedge vif.BAUDTICK);

      // Publish observation
      tx_obs_ap.write(it);
      `uvm_info("UART_MON", $sformatf("Observed TX byte: 0x%02h", it.data), UVM_LOW);
    end
  endtask
endclass

