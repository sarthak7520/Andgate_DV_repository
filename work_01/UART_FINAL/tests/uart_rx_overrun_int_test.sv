//------------------------------------------------------------
// 4. uart_rx_overrun_int_test
//------------------------------------------------------------
class uart_rx_overrun_int_test extends uvm_test;
  `uvm_component_utils(uart_rx_overrun_int_test)

  apb_uart_env env;
  apb_write_seq w_baud, w_ctrl;
  uart_inject_seq rx_data[$];

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env    = apb_uart_env::type_id::create("env", this);
    w_baud = apb_write_seq::type_id::create("w_baud");
    w_ctrl = apb_write_seq::type_id::create("w_ctrl");

    for (int i = 0; i <= 20; i++) begin
      uart_inject_seq tmp_seq = uart_inject_seq::type_id::create($sformatf("rx_%0d", i));
      tmp_seq.data = $urandom_range(8'hFF);
      rx_data.push_back(tmp_seq);
    end
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "Running UART RX Overrun with Interrupt test", UVM_LOW)

    w_baud.addr = ADDR_BAUDDIV; w_baud.data = 32'd27;
    w_baud.start(env.apb_ag.m_sequencer);

    w_ctrl.addr = ADDR_CTRL; w_ctrl.data = 32'h2 | 32'h100; // RXEN + RX overrun int enable
    w_ctrl.start(env.apb_ag.m_sequencer);

    foreach (rx_data[i]) begin
      rx_data[i].start(env.apb_ag.m_sequencer);
      #100;
    end

    `uvm_info("UART_RX_OVERRUN_INT", "Check interrupt status for RX overrun", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
