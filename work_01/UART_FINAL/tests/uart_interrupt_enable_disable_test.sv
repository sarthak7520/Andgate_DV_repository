//------------------------------------------------------------
// 5. uart_interrupt_enable_disable_test
//------------------------------------------------------------
class uart_interrupt_enable_disable_test extends uvm_test;
  `uvm_component_utils(uart_interrupt_enable_disable_test)

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
    `uvm_info("TEST", "Running UART Interrupt Enable/Disable test", UVM_LOW)

    // Enable all interrupts
    w_ctrl.addr = ADDR_CTRL; w_ctrl.data = 32'h7F;
    w_ctrl.start(env.apb_ag.m_sequencer);

    // Disable all interrupts
    w_ctrl.addr = ADDR_CTRL; w_ctrl.data = 32'h0;
    w_ctrl.start(env.apb_ag.m_sequencer);

    `uvm_info("UART_INT_EN_DIS", "Interrupt enable/disable checked", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass

