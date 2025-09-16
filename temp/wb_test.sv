
//=====================================
// Reset Test
//===========t ==========================
class reset_test extends uvm_test;
  `uvm_component_utils(reset_test)

  wb_env env;

  function new(string name="reset_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = wb_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    reset_seq seq;
    phase.raise_objection(this);

    seq = reset_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
  #1000
    phase.drop_objection(this);
  endtask
endclass


//=====================================
//Write Test

class write_test extends uvm_test;
  `uvm_component_utils(write_test)

  wb_env env;
  write_seq seq;

  function new(string name="write_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = wb_env::type_id::create("env", this);
     seq = write_seq::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);
    //write_seq seq;
    phase.raise_objection(this);
$display("---------write_test: run _phase----------------");
   
    seq.start(env.agent.seqr);
  #1000;
    phase.drop_objection(this);
    $display("---------write_test: objection dropped----------------");
  endtask
endclass



 class sdram_test extends uvm_test;
  `uvm_component_utils(sdram_test)

  wb_env env;
  write_seq w_seq;
  read_seq r_seq;

  function new(string name="sdram_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = wb_env::type_id::create("env", this);
     w_seq = write_seq::type_id::create("w_seq");
     r_seq = read_seq::type_id::create("r_seq");
  endfunction

  task run_phase(uvm_phase phase);
    //write_seq seq;
    fork
      begin
    phase.raise_objection(this);    
    $display("---------------start_run_phase-----------");
    w_seq.start(env.agent.seqr);
      
    #500;
    
    $display("_____________read_seq started");
    r_seq.start(env.agent.seqr);
    $display("_____________read_seq ended");
      end
      begin
        #200000 ;
           phase.drop_objection(this);
      end
    join

     $display("--------------end_run_phase---------------");
  endtask
  endclass
//=====================================
// Read Test
//=====================================
class read_test extends uvm_test;
  `uvm_component_utils(read_test)

  wb_env env;

  function new(string name="read_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = wb_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    read_seq seq;
    phase.raise_objection(this);

    seq = read_seq::type_id::create("seq");
    seq.start(env.agent.seqr);
  #100000;
    phase.drop_objection(this);
  endtask
endclass
//=====================================
// Write + Read Test
//=====================================
// class write_read_test extends uvm_test;
//   `uvm_component_utils(write_read_test)

//   wb_env env;
//   write_read_seq seq;

//   function new(string name="write_read_test", uvm_component parent=null);
//     super.new(name, parent);
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     env = wb_env::type_id::create("env", this);
//   endfunction

//   task run_phase(uvm_phase phase);
//     write_read_seq seq;
//     phase.raise_objection(this);

//     seq = write_read_seq::type_id::create("seq");
//     seq.start(env.agent.seqr);

//     phase.drop_objection(this);
//   endtask
// endclass


// // Bank Access Test
// //=====================================
// class bank_access_test extends uvm_test;
//   `uvm_component_utils(bank_access_test)
//   bank_access_seq seq;
//   wb_env env;

//   function new(string name="bank_access_test", uvm_component parent=null);
//     super.new(name, parent);
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     env = wb_env::type_id::create("env", this);
//   endfunction

//   task run_phase(uvm_phase phase);
//     bank_access_seq seq;
//     phase.raise_objection(this);

//     seq = bank_access_seq::type_id::create("seq");
//     seq.start(env.agent.seqr);

//     phase.drop_objection(this);
//   endtask
// endclass

// class wb_test extends wb_test;
//     `uvm_component_utils(wb_test)
//      wb_env env;
    
//     function new(string name = "wb_test", uvm_component parent = null);
//       super.new(name,parent);
//     endfunction
    
//     function void build_phase(uvm_phase phase);
//       super.build_phase(phase);
//       env = wb_env::type_id::create("env", this);
//     endfunction
//     endclass




// class wb_test_1 extends wb_test;;
//   `uvm_component_utils(wb_test_1)
//   reset_seq base_seq;
//   // wb_sequence seq;
  

//   // reset_seq base_seq;
//     // <-- you declared only base_seq here

//   function new(string name = "reset_seq", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     //env = wb_env::type_id::create("env", this);
//   //  seq = wb_sequence::type_id::create("seq", this);
//      base_seq = reset_seq::type_id::create("reset_seq", this);
//     // seq = write_seq::type_id::create("seq", this);
    
//   endfunction

//   task run_phase(uvm_phase phase);
//   super.run_phase(phase);
  
// // seq_1 =write_seq::type_id::create("seq_1");

//      $display("wb_test: run _phase");
//     phase.raise_objection(this);
//     //  seq.start(env.agent.seqr);
//      base_seq.start(env.agent.seqr);

//     #1000;
//      phase.drop_objection(this);
//       $display("wb_test: triggering the seq");
//   endtask
//   endclass



//   class  wb_test extends uvm_test;
//   `uvm_component_utils(wb_test)
//    //write_seq seq_1;
//     wb_env env;
//   // wb_sequence seq;
//   write_read_seq  base_seq;
//   // reset_seq base_seq;
//     // <-- you declared only base_seq here

//   function new(string name = "wb_test", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     env = wb_env::type_id::create("env", this);
//   //  seq = wb_sequence::type_id::create("seq", this);
//     // base_seq = reset_seq::type_id::create("reset_seq", this);
//     base_seq = write_read_seq ::type_id::create("base_seq");
    
//   endfunction

//   task run_phase(uvm_phase phase);
//   super.run_phase(phase);
  
// // seq_1 =write_seq::type_id::create("seq_1");

//      $display("wb_test: run _phase");
//     phase.raise_objection(this);
//      base_seq.start(env.agent.seqr);
//     //  base_seq.start(env.agent.seqr);
//      phase.drop_objection(this);
//       $display("wb_test: triggering the seq::: objection dropped");
//       $display("-----------------test_completed-------------------");
//   endtask
//   endclass

