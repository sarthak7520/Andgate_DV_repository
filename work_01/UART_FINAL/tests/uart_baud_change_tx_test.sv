//------------------------------------------------------------
// 11. uart_baud_change_tx_test
//------------------------------------------------------------
class uart_baud_change_tx_test extends uvm_test;
  `uvm_component_utils(uart_baud_change_tx_test)

  apb_uart_env env;
  apb_write_seq w_baud, w_ctrl;
  apb_write_seq w_data[$];

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env    = apb_uart_env::type_id::create("env",this);
    w_baud = apb_write_seq::type_id::create("w_baud");
    w_ctrl = apb_write_seq::type_id::create("w_ctrl");

    for (int i = 0; i < 10; i++) begin
      apb_write_seq tmp_seq = apb_write_seq::type_id::create($sformatf("tx_%0d",i));
      tmp_seq.addr = ADDR_DATA;
      tmp_seq.data = $urandom_range(8'hFF);
      w_data.push_back(tmp_seq);
    end
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST","Running UART Baud Change During TX Test",UVM_LOW)

    w_ctrl.addr = ADDR_CTRL; w_ctrl.data = 32'h1; // TXEN
    w_ctrl.start(env.apb_ag.m_sequencer);

    foreach (w_data[i]) begin
      w_data[i].start(env.apb_ag.m_sequencer);
      #100;
    end

    w_baud.addr = ADDR_BAUDDIV; w_baud.data = 32'd40;
    w_baud.start(env.apb_ag.m_sequencer);

    `uvm_info("UART_BAUD_TX","Baud changed during TX operation",UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
