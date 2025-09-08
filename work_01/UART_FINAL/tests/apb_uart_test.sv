 `include "uvm_macros.svh"
import uvm_pkg::*;
class apb_uart_test extends uvm_test;
  `uvm_component_utils(apb_uart_test)

  apb_uart_env env;
  
  function new(string name="apb_uart_test" , uvm_component parent= null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_uart_env::type_id::create("env", this);
  endfunction
 // --------------------------------------------------------
  apb_write_seq w;
  apb_read_seq  r;
  uart_inject_seq u;
  byte unsigned tx_stream[$];
  byte unsigned rx_stream[$];
  int i, j, k;
 task run_phase(uvm_phase phase);
  phase.raise_objection(this);

  // --------------------------------------------------------
  // Declare everything UP FRONT
  

  // initialize arrays
  tx_stream = '{8'h55,8'hA5,8'h3C,8'hC3};
  rx_stream = '{8'h11,8'h22,8'h7E,8'h80};

  // --------------------------------------------------------
  // Program BAUDDIV and enable TX/RX via CTRL register
  // --------------------------------------------------------
  w = apb_write_seq::type_id::create("w_baud");
  w.addr = ADDR_BAUDDIV;
  w.data = 32'd27;        // 50 MHz PCLK, 115200 baud, x16 oversample => BAUDDIV=27
  w.start(env.apb_ag.m_sequencer);

  w = apb_write_seq::type_id::create("w_ctrl");
  w.addr = ADDR_CTRL;
  w.data = 32'h3;  // TXEN | RXEN
  w.start(env.apb_ag.m_sequencer);

  // --------------------------------------------------------
  // Drive TX via APB writes (predictor sets TX expected)
  // --------------------------------------------------------
  foreach (tx_stream[i]) begin
    w = apb_write_seq::type_id::create($sformatf("w_tx_%0d", i));
    w.addr = ADDR_DATA;
    w.data = {24'h0, tx_stream[i]};
    w.start(env.apb_ag.m_sequencer);
    #(300ns);
  end

  // --------------------------------------------------------
  // Inject RX bytes on RXD 
  // --------------------------------------------------------
  foreach (rx_stream[j]) begin
    u = uart_inject_seq::type_id::create($sformatf("u_%0d", j));
    u.data = rx_stream[j];
    u.start(env.uart_ag.m_sequencer);
    #(400ns);
  end

  // --------------------------------------------------------
  // Read back RX bytes via APB
  // --------------------------------------------------------
  foreach (rx_stream[k]) begin
    r = apb_read_seq::type_id::create($sformatf("r_%0d", k));
    r.addr = ADDR_DATA;
    r.start(env.apb_ag.m_sequencer);
    #(300ns);
  end

  #(2000ns);
  phase.drop_objection(this);
endtask

endclass
