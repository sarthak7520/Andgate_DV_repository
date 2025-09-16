`timescale 1ns/1ps
`include "uvm_macros.svh"
//`include "wb_pkg.sv"
//import uvm_pkg::*;

`include "wb_pkg.sv"
//import wb_pkg::*;

// tb_top.sv - Top-level testbench, with wb_if and SDRAM model instantiation

module top;
  import uvm_pkg::*;
  import wb_pkg::*;

  // Parameters (kept as original)
  parameter P_SYS  = 10;     // 200 MHz period = 10 ns
  parameter P_SDR  = 20;     // 100 MHz period = 20 ns

  // General
  // reg            RESETN;
  logic          RESETN;
  logic            clk;
  reg            sdram_clk;
  reg            sys_clk;

  initial sys_clk = 0;
  initial sdram_clk = 0;

  always #(P_SYS/2)  sys_clk    = !sys_clk;
  always #(P_SDR/2)  sdram_clk  = !sdram_clk;

  parameter      dw              = 32;  // data width
  parameter      tw              = 8;   // tag id width
  parameter      bl              = 5;   // burst_length_width

  //-------------------------------------------
  // Wishbone interface instance (virtual to UVM)
  //-------------------------------------------
  // Make sure wb_if is compiled/available
    wb_if wb_vif(.clk(sys_clk), .RESETN(RESETN)); 
  // interface declared earlier by you


  //--------------------------------------------
  // SDRAM I/F signals (same as original)
  //--------------------------------------------
`ifdef SDR_32BIT
   wire [31:0]           Dq;       // SDRAM Read/Write Data Bus
   wire [3:0]            sdr_dqm;  // SDRAM DATA Mask
`elsif SDR_16BIT
   wire [15:0]           Dq;
   wire [1:0]            sdr_dqm;
`else
   wire [7:0]            Dq;
   wire [0:0]            sdr_dqm;
`endif

  wire [1:0]            sdr_ba;        // Bank select
  wire [12:0]           sdr_addr;      // SDRAM address
  wire                 sdr_init_done; // SDRAM init done
  wire                  sdr_cke;
  wire                  sdr_cs_n;
  wire                  sdr_ras_n;
  wire                  sdr_cas_n;
  wire                  sdr_we_n;

  // to fix the sdram interface timing issue (keeps original)
  wire #(2.0) sdram_clk_d = sdram_clk;

  //--------------------------------------------
  // DUT instantiation (sdrc_top) with Wishbone wired to wb_vif
  //--------------------------------------------
`ifdef SDR_32BIT
   sdrc_top #(.SDR_DW(32), .SDR_BW(4)) u_dut (
`elsif SDR_16BIT
   sdrc_top #(.SDR_DW(16), .SDR_BW(2)) u_dut (
`else
   sdrc_top #(.SDR_DW(8),  .SDR_BW(1)) u_dut (
`endif
      // System configuration parameters
`ifdef SDR_32BIT
          .cfg_sdr_width      (2'b00), // 32-bit SDRAM
`elsif SDR_16BIT
          .cfg_sdr_width      (2'b01), // 16-bit SDRAM
`else
          .cfg_sdr_width      (2'b10), // 8-bit SDRAM
`endif
          .cfg_colbits        (2'b00), // 8-bit column address

    /* WISHBONE */
          .wb_rst_i           (!RESETN),
          .wb_clk_i           (sys_clk),

          // connect DUT Wishbone ports to the interface signals
          .wb_stb_i           (wb_vif.wb_stb_i),
          .wb_ack_o           (wb_vif.wb_ack_o),
          .wb_addr_i          (wb_vif.wb_addr_i),
          .wb_we_i            (wb_vif.wb_we_i),
          .wb_dat_i           (wb_vif.wb_dat_i),
          .wb_sel_i           (wb_vif.wb_sel_i),
          .wb_dat_o           (wb_vif.wb_dat_o),
          .wb_cyc_i           (wb_vif.wb_cyc_i),
          .wb_cti_i           (wb_vif.wb_cti_i),

    /* Interface to SDRAMs */
          .sdram_clk          (sdram_clk),
          .sdram_resetn       (RESETN),
          .sdr_cs_n           (sdr_cs_n),
          .sdr_cke            (sdr_cke),
          .sdr_ras_n          (sdr_ras_n),
          .sdr_cas_n          (sdr_cas_n),
          .sdr_we_n           (sdr_we_n),
          .sdr_dqm            (sdr_dqm),
          .sdr_ba             (sdr_ba),
          .sdr_addr           (sdr_addr),
          .sdr_dq             (Dq),

    /* Parameters (kept as original values) */
          .sdr_init_done      (sdr_init_done), // tie to 1 for simplicity; use sdr_init_done if you implement init sequence
          .cfg_req_depth      (2'h3),
          .cfg_sdr_en         (1'b1),
          .cfg_sdr_mode_reg   (13'h033),
          .cfg_sdr_tras_d     (4'h4),
          .cfg_sdr_trp_d      (4'h2),
          .cfg_sdr_trcd_d     (4'h2),
          .cfg_sdr_cas        (3'h3),
          .cfg_sdr_trcar_d    (4'h7),
          .cfg_sdr_twr_d      (4'h1),
          .cfg_sdr_rfsh       (12'h100),
          .cfg_sdr_rfmax      (3'h6)
   );
  //--------------------------------------------

  // Instantiate SDRAM model(s) depending on width
`ifdef SDR_32BIT
  mt48lc2m32b2 #(.data_bits(32)) u_sdram32 (
          .Dq    (Dq),
          .Addr  (sdr_addr[10:0]),    // model expects 11-bit addr
          .Ba    (sdr_ba),
          .Clk   (sdram_clk_d),
          .Cke   (sdr_cke),
          .Cs_n  (sdr_cs_n),
          .Ras_n (sdr_ras_n),
          .Cas_n (sdr_cas_n),
          .We_n  (sdr_we_n),
          .Dqm   (sdr_dqm)
  );
`elsif SDR_16BIT
  IS42VM16400K u_sdram16 (
          .dq   (Dq),
          .addr (sdr_addr[11:0]),
          .ba   (sdr_ba),
          .clk  (sdram_clk_d),
          .cke  (sdr_cke),
          .csb  (sdr_cs_n),
          .rasb (sdr_ras_n),
          .casb (sdr_cas_n),
          .web  (sdr_we_n),
          .dqm  (sdr_dqm)
  );
`else
  mt48lc8m8a2 #(.data_bits(8)) u_sdram8 (
          .Dq    (Dq),
          .Addr  (sdr_addr[11:0]),
          .Ba    (sdr_ba),
          .Clk   (sdram_clk_d),
          .Cke   (sdr_cke),
          .Cs_n  (sdr_cs_n),
          .Ras_n (sdr_ras_n),
          .Cas_n (sdr_cas_n),
          .We_n  (sdr_we_n),
          .Dqm   (sdr_dqm)
  );
`endif

  // Reset sequence (kept similar to your original TB)

//  initial begin
//    RESETN = 1'b1;
//    #10;
//    // assert reset
//    RESETN = 1'b0;
//    #100;
//    // release reset
//    RESETN = 1'b1;
//    //#10;
//   // sdr_init_done = 1'b1; // for simplicity, assume SDRAM init is done after reset
 // end

  // Pass virtual interface to UVM via uvm_config_db
  initial begin
    // make sure UVM components retrieve this with key "wb_vif"
    uvm_config_db#(virtual wb_if)::set(null, "*", "vif", wb_vif);
  end

  // Start UVM
  initial begin
    //run_test("write_test");
     run_test("sdram_test");
     //run_test("reset_seq");
      // kicks off UVM (your test will start and the driver can use wb_vif)
  end

  initial begin 
    #10000000;
    $finish;
  end

  initial begin //{
  //ErrCnt          = 0;
  wb_vif.wb_addr_i      = 0;
   wb_vif.wb_dat_i      = 0;
   wb_vif.wb_sel_i       = 4'h0;
   wb_vif.wb_we_i        = 0;
   wb_vif.wb_stb_i       = 0;
   wb_vif.wb_cyc_i       = 0;


  RESETN    = 1'h1;

 #100
  // Applying reset
  RESETN    = 1'h0;
  #10000;
  // Releasing reset
  RESETN    = 1'h1;
  #1000;
  wait(u_dut.sdr_init_done == 1);

  #1000;

  end
endmodule
