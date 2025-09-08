class apb_uart_env extends uvm_env;
  `uvm_component_utils(apb_uart_env)
  apb_agent       apb_ag;
  uart_agent      uart_ag;
  uart_scoreboard scb;
  apb_predictor   pred;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    apb_ag = apb_agent      ::type_id::create("apb_ag", this);
    uart_ag= uart_agent     ::type_id::create("uart_ag", this);
    scb    = uart_scoreboard::type_id::create("scb",    this);
    pred   = apb_predictor  ::type_id::create("pred",   this);
  endfunction
  function void connect_phase(uvm_phase phase);
    apb_ag.m_monitor.ap.connect(pred.ap_export); // APB -> predictor
    pred.scb = scb;                               // predictor -> scoreboard (handle)
    uart_ag.m_monitor.tx_obs_ap.connect(scb.tx_obs_imp); // TX observed
    uart_ag.m_driver .rx_exp_ap.connect(scb.rx_exp_imp); // RX expected
  endfunction
endclass
