class apb_predictor extends uvm_component;
  `uvm_component_utils(apb_predictor)
  uvm_analysis_export#(apb_item) ap_export; // connect APB monitor here
  uvm_tlm_analysis_fifo#(apb_item) fifo;
  uart_scoreboard scb;
  function new(string name, uvm_component parent); super.new(name,parent); ap_export=new("ap_export",this); endfunction
  function void build_phase(uvm_phase phase); fifo = new("fifo", this); endfunction
  function void connect_phase(uvm_phase phase); ap_export.connect(fifo.analysis_export); endfunction
  task run_phase(uvm_phase phase);
    apb_item tr; uart_item u;
    forever begin
      fifo.get(tr);
      if(tr.write && tr.addr == ADDR_DATA) begin
        u = uart_item::type_id::create("tx_exp_from_apb"); u.data = tr.wdata[7:0]; scb.tx_exp_imp.write(u);
      end
      if(!tr.write && tr.addr == ADDR_DATA) begin
        u = uart_item::type_id::create("rx_obs_from_apb"); u.data = tr.rdata[7:0]; scb.rx_obs_imp.write(u);
      end
    end
  endtask
endclass
