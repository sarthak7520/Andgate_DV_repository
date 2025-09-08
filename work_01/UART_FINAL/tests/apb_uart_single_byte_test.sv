 `include "uvm_macros.svh"
import uvm_pkg::*;
class apb_uart_single_byte_test extends uvm_test;
  `uvm_component_utils(apb_uart_single_byte_test)

    apb_uart_env env;
    apb_write_seq w_seq;
    apb_read_seq  r_seq;
    uart_inject_seq u_seq;
    byte unsigned tx_byte = 8'hA5;
    byte unsigned rx_byte = 8'h5A;

  function new(string name="apb_uart_single_byte_test" , uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_uart_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    

    

    // --------------------------------------------------------
    // Configure UART: BAUDDIV and CTRL
    // --------------------------------------------------------
    w_seq = apb_write_seq::type_id::create("w_baud");
    w_seq.addr = ADDR_BAUDDIV;
    w_seq.data = 32'd27;
    w_seq.start(env.apb_ag.m_sequencer);

    w_seq = apb_write_seq::type_id::create("w_ctrl");
    w_seq.addr = ADDR_CTRL;
    w_seq.data = 32'h3; // TXEN | RXEN
    w_seq.start(env.apb_ag.m_sequencer);
   // wait(w_seq.is_done);                             //raju
    #(200ns)
    // --------------------------------------------------------
    // Transmit one byte via APB
    // --------------------------------------------------------
    w_seq = apb_write_seq::type_id::create("w_tx");
    w_seq.addr = ADDR_DATA;
    w_seq.data = {24'h0, tx_byte};
    w_seq.start(env.apb_ag.m_sequencer);
    #(300ns);


    // --------------------------------------------------------
    // Inject one RX byte via UART agent
    // --------------------------------------------------------
    u_seq = uart_inject_seq::type_id::create("u_rx");
    u_seq.data = rx_byte;
    u_seq.start(env.uart_ag.m_sequencer);
    #(400ns);

    // --------------------------------------------------------
    // Read back RX byte via APB
    // --------------------------------------------------------
    r_seq = apb_read_seq::type_id::create("r_rx");
    r_seq.addr = ADDR_DATA;
    r_seq.start(env.apb_ag.m_sequencer);
    #(300ns);

    phase.drop_objection(this);
  endtask
endclass

