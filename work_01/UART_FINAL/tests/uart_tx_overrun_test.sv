class uart_tx_overrun_test extends uvm_test;
  `uvm_component_utils(uart_tx_overrun_test)

  // Environment and sequences
  apb_uart_env     env;
  apb_write_seq    w_baud, w_ctrl;
  apb_write_seq    w_data[$];  // dynamic array for multiple TX writes

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create environment
    env    = apb_uart_env::type_id::create("env", this);

    // Create control sequences
    w_baud = apb_write_seq::type_id::create("w_baud");
    w_ctrl = apb_write_seq::type_id::create("w_ctrl");

    // Prepare multiple TX writes to force FIFO overrun
    for (int i = 0; i <= 20; i++) begin
      apb_write_seq tmp_seq;
      tmp_seq = apb_write_seq::type_id::create($sformatf("w_tx_%0d", i));
      tmp_seq.addr = ADDR_DATA;
      tmp_seq.data = $urandom_range(8'hFF);
      w_data.push_back(tmp_seq);
    end
  endfunction

  // Run phase
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "Running UART TX Overrun test", UVM_LOW)

    // Configure baud rate
    w_baud.addr = ADDR_BAUDDIV;
    w_baud.data = 32'd27;
    w_baud.start(env.apb_ag.m_sequencer);

    // Enable TX only
    w_ctrl.addr = ADDR_CTRL;
    w_ctrl.data = 32'h1;  // TXEN only
    w_ctrl.start(env.apb_ag.m_sequencer);

    // Write too many bytes into TX FIFO to cause overrun
    foreach (w_data[i]) begin
      w_data[i].start(env.apb_ag.m_sequencer);
      #100;  // delay for simulation, adjust per timescale
    end

    // Check STATUS register or scoreboard for TX overrun flag
    `uvm_info("UART_TX_OVERRUN", "Check STATUS for TX overrun flag", UVM_LOW)

    phase.drop_objection(this);
  endtask

endclass
