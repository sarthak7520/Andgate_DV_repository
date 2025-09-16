//=====================================
// Reset Sequence
//=====================================
class reset_seq extends uvm_sequence #(wb_transaction);
  `uvm_object_utils(reset_seq)

  virtual wb_if vif;

  function new(string name="reset_seq");
    super.new(name);
  endfunction

  task body();
    if (!uvm_config_db#(virtual wb_if)::get(null, "*", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface 'vif' not found in config DB")

    @(posedge vif.clk);

    if (vif.RESETN == 0) begin
      `uvm_info("RESET_SEQ", "Reset is asserted, waiting for deassert...", UVM_LOW)
      wait (vif.RESETN == 1);
      @(posedge vif.clk);
    end

    `uvm_info("RESET_SEQ", "Reset deasserted. DUT ready.", UVM_LOW)
  endtask
endclass




//=====================================
// Write Sequence
//=====================================
class write_seq extends uvm_sequence#(wb_transaction);
  `uvm_object_utils(write_seq)
 wb_transaction tr;
  function new(string name="write_seq");
    super.new(name);
  endfunction

  virtual task body();
   
    tr = wb_transaction::type_id::create("tr");

repeat(5) begin
    start_item(tr);
    assert (tr.randomize() with {addr == {32'h4_0000, 8'h4};data == 4'h5;we   == 1'b1; });
    finish_item(tr);
    $display("__________write_end________");  

    `uvm_info("WRITE_SEQ", $sformatf("Wrote addr=0x%0h data=0x%0h", tr.addr, tr.data), UVM_MEDIUM)
end
  endtask
endclass


//=====================================
// Read Sequence
//=====================================
class read_seq extends uvm_sequence#(wb_transaction);
  `uvm_object_utils(read_seq)
 
  function new(string name="read_seq");
    super.new(name);
  endfunction
//  $display("__________read_start________");
  virtual task body();
    wb_transaction tr;
    tr = wb_transaction::type_id::create("tr");
 $display("__________read_start________");
    start_item(tr);
    assert (tr.randomize() with {addr == {32'h4_0000, 8'h4}; we == 1'b0; });
    // assert(tr.randomize() with {
    //   addr == 32'h4_0000, 8'h4 // same address as write
    //   we   == 1'b0;
  
    finish_item(tr);
   $display("__________read_end________");
    `uvm_info("READ_SEQ", $sformatf("Read data=0x%0h from addr=0x%0h", tr.rdata, tr.addr), UVM_MEDIUM)
  endtask
endclass


// class bank_access_seq extends uvm_sequence #(wb_transaction);
//   `uvm_object_utils(bank_access_seq)

//   function new(string name="bank_access_seq");
//     super.new(name);
//   endfunction

//  virtual task body();
//     wb_transaction tr;
    
//     // Assuming 4 banks, addr[13:12] selects the bank
//     foreach (int bank[0:3]) begin
//       tr = wb_transaction::type_id::create($sformatf("tr_bank%d", bank));
//       start_item(tr);
//       assert(tr.randomize() with {
//         addr[13:12] == bank;  // constrain bank bits
//         we == 1'b1;           // write
//         data inside {[32'h10 : 32'h1F]}; // some data range
//       });
//       finish_item(tr);
//       `uvm_info(get_type_name(), $sformatf("Accessed Bank %0d : addr=0x%0h data=0x%0h", bank, tr.addr, tr.data), UVM_MEDIUM)
//     end
//   endtask
// endclass


