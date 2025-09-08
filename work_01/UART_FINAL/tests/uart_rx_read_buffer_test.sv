//------------------------------------------------------------
// 12. uart_rx_read_buffer_test
//------------------------------------------------------------
class uart_rx_read_buffer_test extends uvm_test;
  `uvm_component_utils(uart_rx_read_buffer_test)

  apb_uart_env env;
  uart_inject_seq rx_data[$];
  apb_read_seq r_data;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_uart_env::type_id::create("env",this);
    r_data = apb_read_seq::type_id::create("r_data");

    for (int i = 0; i < 10; i++) begin
      uart_inject_seq tmp_seq = uart_inject_seq::type_id::create($sformatf("rx_%0d",i));
      tmp_seq.data = $urandom_range(8'hFF);
      rx_data.push_back(tmp_seq);
    end
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST","Running UART RX Read Buffer Test",UVM_LOW)

    foreach (rx_data[i]) begin
      rx_data[i].start(env.apb_ag.m_sequencer);
      #100;
    end

    r_data.addr = ADDR_DATA;
    r_data.start(env.apb_ag.m_sequencer);

    `uvm_info("UART_RX_READ","Read RX buffer successfully",UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
