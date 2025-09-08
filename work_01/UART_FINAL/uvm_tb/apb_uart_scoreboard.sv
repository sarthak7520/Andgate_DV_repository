`uvm_analysis_imp_decl(_tx_exp)
`uvm_analysis_imp_decl(_tx_obs)
`uvm_analysis_imp_decl(_rx_exp)
`uvm_analysis_imp_decl(_rx_obs)

class uart_scoreboard extends uvm_component;
  `uvm_component_utils(uart_scoreboard)
  uvm_analysis_imp_tx_exp#(uart_item, uart_scoreboard) tx_exp_imp;
  uvm_analysis_imp_tx_obs#(uart_item, uart_scoreboard) tx_obs_imp;
  uvm_analysis_imp_rx_exp#(uart_item, uart_scoreboard) rx_exp_imp;
  uvm_analysis_imp_rx_obs#(uart_item, uart_scoreboard) rx_obs_imp;
  uart_item tx_exp_q[$];
  uart_item tx_obs_q[$];
  uart_item rx_exp_q[$];
  uart_item rx_obs_q[$];
  function new(string name, uvm_component parent);
    super.new(name,parent);
    tx_exp_imp = new("tx_exp_imp", this);
    tx_obs_imp = new("tx_obs_imp", this);
    rx_exp_imp = new("rx_exp_imp", this);
    rx_obs_imp = new("rx_obs_imp", this);
  endfunction
  function void write_tx_exp(uart_item t); tx_exp_q.push_back(t); compare_tx(); endfunction
  function void write_tx_obs(uart_item t); tx_obs_q.push_back(t); compare_tx(); endfunction
  function void write_rx_exp(uart_item t); rx_exp_q.push_back(t); compare_rx(); endfunction
  function void write_rx_obs(uart_item t); rx_obs_q.push_back(t); compare_rx(); endfunction
  function void compare_tx();
    while(tx_exp_q.size() && tx_obs_q.size()) begin
      uart_item e = tx_exp_q.pop_front();
      uart_item o = tx_obs_q.pop_front();
      if(o.data !== e.data)
        `uvm_error("TX_MISCOMPARE", $sformatf("Expected TX=0x%02h Observed=0x%02h", e.data, o.data))
      else
        `uvm_info("TX_MATCH", $sformatf("TX matched 0x%02h", o.data), UVM_LOW);
    end
  endfunction
  function void compare_rx();
    while(rx_exp_q.size() && rx_obs_q.size()) begin
      uart_item e = rx_exp_q.pop_front();
      uart_item o = rx_obs_q.pop_front();
      if(o.data !== e.data)
        `uvm_error("RX_MISCOMPARE", $sformatf("Expected RX=0x%02h Observed=0x%02h", e.data, o.data))
      else
        `uvm_info("RX_MATCH", $sformatf("RX matched 0x%02h", o.data), UVM_LOW);
    end
  endfunction
endclass
