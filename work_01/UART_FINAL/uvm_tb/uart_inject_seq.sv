class uart_inject_seq extends uvm_sequence#(uart_item);
  `uvm_object_utils(uart_inject_seq)
  rand bit [7:0] data;
  function new(string name="uart_inject_seq"); super.new(name); endfunction
  task body();
    uart_item it = uart_item::type_id::create("inj");
    start_item(it);
    it.data = data; 
    finish_item(it);
  endtask
endclass
