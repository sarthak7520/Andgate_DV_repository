//interface wb_if(input logic sys_clk);
interface wb_if (input logic clk, input logic RESETN);
  logic             wb_stb_i;
  logic             wb_ack_o;
  logic [25:0]      wb_addr_i;
  logic             wb_we_i;
  logic [31:0]      wb_dat_i;
  logic [31:0]      wb_dat_o;
  logic [3:0]       wb_sel_i;
  logic             wb_cyc_i;
  logic [2:0]       wb_cti_i;
  logic [31:0]      wb_rdata_0;
endinterface

