//------------------------------------------------------------
// 14. uart_rxint_trigger_test
//------------------------------------------------------------
class uart_rxint_trigger_test extends uvm_test;
  `uvm_component_utils(uart_rxint_trigger_test)

  apb_uart_env env;
  apb_write_seq w_ctrl;
  uart_inject_seq rx_data;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_uart_env::type_id::create("env",this);
    w_ctrl = apb_write_seq::type_id::create("w_ctrl");
    rx_data = uart_inject_seq::type_id::create("rx_data");
    rx_data.data = 8'h55;
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST","Running UART RX Interrupt Trigger Test",UVM_LOW)

    w_ctrl.addr = ADDR_CTRL; w_ctrl.data = 32'h202; // RXEN + RX interrupt enable
    w_ctrl.start(env.apb_ag.m_sequencer);

    rx_data.start(env.apb_ag.m_sequencer);
    #100;

    `uvm_info("UART_RX_INT","RX interrupt should trigger",UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

