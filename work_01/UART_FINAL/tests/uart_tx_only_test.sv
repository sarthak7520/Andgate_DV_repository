class uart_tx_only_test extends uvm_test;
  `uvm_component_utils(uart_tx_only_test)

  apb_uart_env env;

  // Sequence handles created in build_phase
  apb_write_seq w_baud, w_ctrl;
  apb_write_seq w_tx[$];      // dynamic array of TX sequences
  byte tx_bytes[] = '{8'h41, 8'h42, 8'h43};
  bit mismatch = 0;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create environment
    env = apb_uart_env::type_id::create("env", this);

    // Create config sequences
    w_baud = apb_write_seq::type_id::create("w_baud");
    w_ctrl = apb_write_seq::type_id::create("w_ctrl");

    // Create TX sequences
    foreach (tx_bytes[i])
      w_tx.push_back(apb_write_seq::type_id::create($sformatf("w_tx_%0d",i)));
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "Running UART TX-only test", UVM_LOW)

    // Configure UART: BAUDDIV & CTRL
    w_baud.addr = ADDR_BAUDDIV;
    w_baud.data = 32'd27; 
    w_baud.start(env.apb_ag.m_sequencer);
    w_ctrl.addr = ADDR_CTRL;   
    w_ctrl.data = 32'h1;  
    w_ctrl.start(env.apb_ag.m_sequencer);

    // Send TX bytes via APB
    foreach (tx_bytes[i]) begin
      w_tx[i].addr = ADDR_DATA;
      w_tx[i].data = {24'h0, tx_bytes[i]};
      w_tx[i].start(env.apb_ag.m_sequencer);
      #(300ns);
    end

    // Wait for transmission
    #(2000ns);

    // --- Verify TX via scoreboard ---
    
    foreach (tx_bytes[i]) begin
      if (i >= env.scb.tx_obs_q.size()) begin
        mismatch = 1;
        `uvm_error("UART_TX_FAIL", $sformatf("Missing observed TX byte for index %0d", i))
      end else if (tx_bytes[i] !== env.scb.tx_obs_q[i].data) begin
        mismatch = 1;
        `uvm_error("UART_TX_FAIL", $sformatf("TX mismatch at index %0d: Expected=0x%02h Observed=0x%02h",
                                             i, tx_bytes[i], env.scb.tx_obs_q[i].data))
      end
    end

    if (!mismatch)
      `uvm_info("UART_TX_PASS", "All TX bytes transmitted correctly", UVM_LOW)

    phase.drop_objection(this);
  endtask
endclass

