class uart_rx_only_test extends uvm_test;
  `uvm_component_utils(uart_rx_only_test)

  apb_uart_env env;

  // Sequence handles
  uart_inject_seq rx_seq[$];    // dynamic array for injected RX bytes
  apb_read_seq  r_seq[$];       // dynamic array for APB reads
  apb_write_seq w_baud;
  apb_write_seq w_ctrl;

  byte rx_bytes[] = '{8'h11, 8'h22, 8'h7E, 8'h80};

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create environment
    env = apb_uart_env::type_id::create("env", this);

    // Create RX inject sequences
    foreach (rx_bytes[i])
      rx_seq.push_back(uart_inject_seq::type_id::create($sformatf("rx_inj_%0d", i)));

    // Create APB read sequences for reading RX DATA
    foreach (rx_bytes[i])
      r_seq.push_back(apb_read_seq::type_id::create($sformatf("r_rx_%0d", i)));

    // Create APB write sequences
    w_baud = apb_write_seq::type_id::create("w_baud");
    w_ctrl = apb_write_seq::type_id::create("w_ctrl");
  endfunction

  task run_phase(uvm_phase phase);
      bit mismatch = 0;

    phase.raise_objection(this);
    `uvm_info("TEST", "Running UART RX-only test", UVM_LOW)

    // -----------------------------
    // Configure UART: BAUDDIV & enable RX
    // -----------------------------
    w_baud.addr = ADDR_BAUDDIV;
    w_baud.data = 32'd27;
    w_baud.start(env.apb_ag.m_sequencer);

    w_ctrl.addr = ADDR_CTRL;
    w_ctrl.data = 32'h2;  // RXEN only
    w_ctrl.start(env.apb_ag.m_sequencer);

    // -----------------------------
    // Inject RX bytes
    // -----------------------------
    foreach (rx_bytes[i]) begin
      rx_seq[i].data = rx_bytes[i];
      rx_seq[i].start(env.uart_ag.m_sequencer);
      #(400ns);
    end

    // -----------------------------
    // Optionally read back RX bytes via APB DATA
    // -----------------------------
    foreach (rx_bytes[i]) begin
      r_seq[i].addr = ADDR_DATA;
      r_seq[i].start(env.apb_ag.m_sequencer);
      #(300ns);
    end

    #(2000ns);

    // -----------------------------
    // Verify RX via scoreboard
    // -----------------------------
    foreach (rx_bytes[i]) begin
      if (i >= env.scb.rx_obs_q.size()) begin
        mismatch = 1;
        `uvm_error("UART_RX_FAIL", $sformatf("Missing observed RX byte for index %0d", i))
      end else if (rx_bytes[i] !== env.scb.rx_obs_q[i].data) begin
        mismatch = 1;
        `uvm_error("UART_RX_FAIL", $sformatf("RX mismatch at index %0d: Expected=0x%02h Observed=0x%02h",
                                             i, rx_bytes[i], env.scb.rx_obs_q[i].data))
      end
    end

    if (!mismatch)
      `uvm_info("UART_RX_PASS", "All RX bytes received correctly", UVM_LOW)

    phase.drop_objection(this);
  endtask
endclass

