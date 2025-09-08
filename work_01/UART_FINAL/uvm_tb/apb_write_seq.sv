class apb_write_seq extends uvm_sequence#(apb_item);
  `uvm_object_utils(apb_write_seq)
  rand bit [9:0]  addr;
  rand bit [31:0] data;
  function new(string name="apb_write_seq"); 
  super.new(name); endfunction
  task body();
    apb_item tr = apb_item::type_id::create("wr");
    start_item(tr); 
    tr.write = 1; 
    tr.addr = addr; 
    tr.wdata = data; 
    finish_item(tr);
  endtask
endclass
