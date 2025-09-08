class apb_uart_soft_reset_test extends uvm_test;
  `uvm_component_utils(apb_uart_soft_reset_test)

  apb_uart_env env;
  apb_write_seq w_seq;
  apb_read_seq  r_seq;
  bit test_pass;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env    = apb_uart_env::type_id::create("env", this);
    w_seq  = apb_write_seq::type_id::create("w_seq", this);
    r_seq  = apb_read_seq ::type_id::create("r_seq", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    test_pass = 1;

    `uvm_info("TEST", "Starting UART soft reset test", UVM_LOW)

    // 1. Trigger soft reset (CTRL = 0)
    w_seq.addr = ADDR_CTRL;
    w_seq.data = 32'h0;
    w_seq.start(env.apb_ag.m_sequencer);
    #(500ns); 

    // 2. Read back CTRL to verify reset
    r_seq.addr = ADDR_CTRL;
    r_seq.start(env.apb_ag.m_sequencer);
    #(200ns);
    if (r_seq.rdata !== 32'h0) begin
      test_pass = 0;
      `uvm_error("SOFT_RESET_FAIL", $sformatf("CTRL not cleared: 0x%08h", r_seq.rdata))
    end

   // Write BAUDDIV = 27
    w_seq.addr = ADDR_BAUDDIV;
    w_seq.data = 32'd27;
    w_seq.start(env.apb_ag.m_sequencer);
    #(200ns);

    // Read back BAUDDIV
    r_seq.addr = ADDR_BAUDDIV;
    r_seq.start(env.apb_ag.m_sequencer);
    #(200ns);
    $display("[%0t] BAUDDIV readback: %0d", $time, r_seq.rdata);

    if (r_seq.rdata !== 32'd27) 
    begin
    `uvm_error("CONFIG_FAIL", $sformatf("BAUDDIV not latched: %0d", r_seq.rdata))
    test_pass = 0;
    end

    // 4. Re-enable TX/RX (CTRL = 3)
    w_seq.addr = ADDR_CTRL;
    w_seq.data = 32'h3;
    w_seq.start(env.apb_ag.m_sequencer);
    #(500ns); // Allow DUT to latch CTRL

    // 5. Read back CTRL to verify re-enable
    r_seq.addr = ADDR_CTRL;
    r_seq.start(env.apb_ag.m_sequencer);
    #(200ns);
    if (r_seq.rdata !== 32'h3) begin
      test_pass = 0;
      `uvm_error("SOFT_RESET_FAIL", $sformatf("CTRL not properly set: 0x%08h", r_seq.rdata))
    end

    // 6. Final result
    if (test_pass)
      `uvm_info("SOFT_RESET_PASS", "Soft reset test PASSED", UVM_LOW)
    else
      `uvm_error("SOFT_RESET_FAIL", "Soft reset test FAILED")

    phase.drop_objection(this);
  endtask
endclass
