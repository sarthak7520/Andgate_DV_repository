
class wb_scoreboard extends uvm_component;
`uvm_component_utils(wb_scoreboard)
  uvm_analysis_imp #(wb_transaction, wb_scoreboard) mon_ap;
  bit [31:0] exp_data[$];//exp_data;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCOREBOARD", "Building scoreboard", UVM_LOW)
    endfunction

  function void write(wb_transaction tr);
  $display("in scoreboard write");
    if (tr.we == 1) begin
      exp_data.push_back(tr.data);
    end else begin
      if (exp_data.size() == 0) begin
        `uvm_error("SCOREBOARD", "Unexpected read with empty expected queue")
      end else begin
        if (tr.rdata !== exp_data.pop_front()) begin
          `uvm_error("SCOREBOARD", $sformatf("Data mismatch at addr %h", tr.addr))
        end else begin
          `uvm_info("SCOREBOARD", "Read data matched", UVM_LOW)
        end
      end
    end
    $display("scoreboard end");
  endfunction
endclass

