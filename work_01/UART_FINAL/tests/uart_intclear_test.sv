//------------------------------------------------------------
// 6. uart_intclear_test
//------------------------------------------------------------
class uart_intclear_test extends uvm_test;
  `uvm_component_utils(uart_intclear_test)

  apb_uart_env env;
  apb_write_seq w_ctrl;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env    = apb_uart_env::type_id::create("env", this);
    w_ctrl = apb_write_seq::type_id::create("w_ctrl");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "Running UART Interrupt Clear test", UVM_LOW)

    w_ctrl.addr = ADDR_CTRL; w_ctrl.data = 32'hFF; // Clear all interrupts
    w_ctrl.start(env.apb_ag.m_sequencer);

    `uvm_info("UART_INT_CLEAR", "All interrupts cleared", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

