class uart_agent extends uvm_agent;
  `uvm_component_utils(uart_agent)
  uart_sequencer m_sequencer;
  uart_driver    m_driver;
  uart_monitor   m_monitor;
  virtual uart_if vif;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual uart_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF","uart_if not set for agent")
    m_sequencer = uart_sequencer::type_id::create("m_sequencer", this);
    m_driver    = uart_driver   ::type_id::create("m_driver",    this);
    m_monitor   = uart_monitor  ::type_id::create("m_monitor",   this);
    uvm_config_db#(virtual uart_if)::set(this, "m_driver" , "vif", vif);
    uvm_config_db#(virtual uart_if)::set(this, "m_monitor", "vif", vif);
  endfunction
  function void connect_phase(uvm_phase phase);
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction
endclass
