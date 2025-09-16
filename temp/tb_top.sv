`timescale 1ns/1ps
module tb_top;

// --------------------------------------------------
// Same signals/parameters as before
// --------------------------------------------------
parameter P_SYS  = 10;     // 200 MHz
parameter P_SDR  = 20;     // 100 MHz

reg RESETN;
reg sdram_clk;
reg sys_clk;

initial sys_clk = 0;
initial sdram_clk = 0;
always #(P_SYS/2) sys_clk = !sys_clk;
always #(P_SDR/2) sdram_clk = !sdram_clk;

parameter dw = 32;  
parameter tw = 8;   
parameter bl = 5;   

// Wishbone signals
reg             wb_stb_i;
wire            wb_ack_o;
reg  [25:0]     wb_addr_i;
reg             wb_we_i;
reg  [dw-1:0]   wb_dat_i;
reg  [dw/8-1:0] wb_sel_i;
wire [dw-1:0]   wb_dat_o;
reg             wb_cyc_i;
reg   [2:0]     wb_cti_i;

// SDRAM signals (unchanged, omitted here for brevity)
// ... <same as your original code for DQ, sdr_addr, etc.>

// Data/address/burst length FIFO
int dfifo[$]; 
int afifo[$]; 
int bfifo[$]; 

reg [31:0] ErrCnt;
reg [31:0] StartAddr;
int k;

// --------------------------------------------------
// DUT + SDRAM Model instantiation (same as your code)
// --------------------------------------------------

// --------------------------------------------------
// Helper tasks
// --------------------------------------------------
task burst_write(input [31:0] Address, input [7:0] bl);
   // same as your original burst_write
endtask

task burst_read;
   // same as your original burst_read
endtask

// --------------------------------------------------
// Test Case Tasks
// --------------------------------------------------
task test_case1_single_rw;
begin
  $display("==== TestCase 1: Single Write/Read ====");
  burst_write(32'h4_0000, 8'h4);
  burst_read();
end
endtask

task test_case2_repeat_rw;
begin
  $display("==== TestCase 2: Repeated Access (Row Hit) ====");
  burst_write(32'h4_0000, 8'h4);
  burst_read();
end
endtask

task test_case3_page_cross;
begin
  $display("==== TestCase 3: Page Boundary Crossing ====");
  burst_write(32'h0000_0FF0,8'h8);  
  burst_write(32'h0001_0FF4,8'hF);  
  burst_write(32'h0002_0FF8,8'hF);  
  burst_read();
  burst_read();
end
endtask

task test_case4_multiple_bursts;
begin
  $display("==== TestCase 4: 4 Write & 4 Read ====");
  burst_write(32'h4_0000,8'h4);  
  burst_write(32'h5_0000,8'h5);  
  burst_write(32'h6_0000,8'h6);  
  burst_write(32'h7_0000,8'h7);  
  burst_read();  
  burst_read();  
  burst_read();  
  burst_read();  
end
endtask

task test_case5_bank_row_interleaving;
begin
  $display("==== TestCase 5: Bank/Row Interleaving ====");
  burst_write({12'h000,2'b00,8'h00,2'b00},8'h4); // Row 0 Bank 0
  burst_write({12'h000,2'b01,8'h00,2'b00},8'h5); // Row 0 Bank 1
  burst_write({12'h001,2'b10,8'h00,2'b00},8'h6); // Row 1 Bank 2
  burst_read();
  burst_read();
  burst_read();
end
endtask

task test_case6_random_access;
begin
  $display("==== TestCase 6: Random Access ====");
  for(k=0; k < 5; k++) begin
     StartAddr = $random & 32'h003FFFFF;
     burst_write(StartAddr,($random & 8'h0f)+1);  
     StartAddr = $random & 32'h003FFFFF;
     burst_write(StartAddr,($random & 8'h0f)+1);  
     burst_read();  
     burst_read();  
  end
end
endtask

// --------------------------------------------------
// Main Test Control
// --------------------------------------------------
initial begin
  ErrCnt = 0;
  wb_addr_i = 0;
  wb_dat_i  = 0;
  wb_sel_i  = 0;
  wb_we_i   = 0;
  wb_stb_i  = 0;
  wb_cyc_i  = 0;

  RESETN = 1;
  #100 RESETN = 0;
  #10000 RESETN = 1;
  wait(u_dut.sdr_init_done == 1);
  #1000;

  // Run tests one by one
  test_case1_single_rw();
  test_case2_repeat_rw();
  test_case3_page_cross();
  test_case4_multiple_bursts();
  test_case5_bank_row_interleaving();
  test_case6_random_access();

  // Final check
  if (ErrCnt == 0)
    $display("✅ STATUS: SDRAM TEST PASSED");
  else
    $display("❌ ERROR: SDRAM TEST FAILED with %0d errors", ErrCnt);

  $finish;
end

endmodule
