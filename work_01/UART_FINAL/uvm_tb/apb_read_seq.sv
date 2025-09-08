class apb_read_seq extends uvm_sequence#(apb_item);
  `uvm_object_utils(apb_read_seq)
  rand bit [9:0]  addr;
       bit [31:0] rdata;
  function new(string name="apb_read_seq"); 
    super.new(name); 
  endfunction
  task body();
    apb_item tr = apb_item::type_id::create("rd");
    start_item(tr); 
    tr.write = 0; 
    tr.addr = addr; 
    tr.wdata = '0; 
    finish_item(tr);
    rdata = tr.rdata;
  endtask
endclass
