class apb_agent extends uvm_agent;
  `uvm_component_utils(apb_agent)
  apb_sequencer m_sequencer;
  apb_driver    m_driver;
  apb_monitor   m_monitor;
  virtual apb_if vif;
  function new(string name, uvm_component parent); super.new(name,parent); endfunction
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF","apb_if not set for agent")
    m_sequencer = apb_sequencer::type_id::create("m_sequencer", this);
    m_driver    = apb_driver   ::type_id::create("m_driver",    this);
    m_monitor   = apb_monitor  ::type_id::create("m_monitor",   this);
    uvm_config_db#(virtual apb_if)::set(this, "m_driver" , "vif", vif);
    uvm_config_db#(virtual apb_if)::set(this, "m_monitor", "vif", vif);
  endfunction
  function void connect_phase(uvm_phase phase);
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction
endclass
