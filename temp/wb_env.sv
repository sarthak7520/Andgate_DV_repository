class wb_env extends uvm_env;
 `uvm_component_utils(wb_env)
  wb_agent       agent;
  //wb_scoreboard  sb;

  function new(string name ="env",uvm_component parent =null);
  super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
  super.build_phase(phase);

    agent = wb_agent::type_id::create("agent", this);
    //sb    = wb_scoreboard::type_id::create("sb", this);
    $display("wb_env::: i am build_phase env");

  endfunction

  function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (agent==null)      `uvm_fatal("NULL","agent null")
if (agent.mon==null)  `uvm_fatal("NULL","agent.mon null")
//if (sb==null)         `uvm_fatal("NULL","sb null")
    //agent.mon.ap.connect(sb.mon_ap);
    
  endfunction
endclass

