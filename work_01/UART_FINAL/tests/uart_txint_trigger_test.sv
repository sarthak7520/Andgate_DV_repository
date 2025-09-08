//------------------------------------------------------------
// 13. uart_txint_trigger_test
//------------------------------------------------------------
class uart_txint_trigger_test extends uvm_test;
  `uvm_component_utils(uart_txint_trigger_test)

  apb_uart_env env;
  apb_write_seq w_ctrl, w_data;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_uart_env::type_id::create("env",this);
    w_ctrl = apb_write_seq::type_id::create("w_ctrl");
    w_data = apb_write_seq::type_id::create("w_data");
    w_data.addr = ADDR_DATA;
    w_data.data = 8'hAA;
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST","Running UART TX Interrupt Trigger Test",UVM_LOW)

    w_ctrl.addr = ADDR_CTRL; w_ctrl.data = 32'h101; // TXEN + TX interrupt enable
    w_ctrl.start(env.apb_ag.m_sequencer);

    w_data.start(env.apb_ag.m_sequencer);
    #100;

    `uvm_info("UART_TX_INT","TX interrupt should trigger",UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
