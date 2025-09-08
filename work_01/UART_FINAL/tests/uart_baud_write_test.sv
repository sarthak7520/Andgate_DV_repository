//------------------------------------------------------------
// 3. uart_baud_write_test
//------------------------------------------------------------
class uart_baud_write_test extends uvm_test;
  `uvm_component_utils(uart_baud_write_test)

  apb_uart_env env;
  apb_write_seq w_baud;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env    = apb_uart_env::type_id::create("env", this);
    w_baud = apb_write_seq::type_id::create("w_baud");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "Running UART Baud Write test", UVM_LOW)

    w_baud.addr = ADDR_BAUDDIV; w_baud.data = 32'd27;
    w_baud.start(env.apb_ag.m_sequencer);

    `uvm_info("UART_BAUD_WRITE", "Check BAUDDIV register value", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
