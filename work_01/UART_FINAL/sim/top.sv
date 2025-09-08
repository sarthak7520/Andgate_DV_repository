
 `include "uvm_macros.svh"
import uvm_pkg::*;
//`include "apb_uart_pkg"
import apb_uart_pkg::*;


/*localparam ADDR_DATA    = 10'h000; // 0x00
localparam ADDR_STATUS  = 10'h004; // 0x04
localparam ADDR_CTRL    = 10'h008; // 0x08
localparam ADDR_INTSTAT = 10'h00C; // 0x0C
localparam ADDR_BAUDDIV = 10'h010; // 0x10*/
`define AFTER_SEQ_DELAY 200ns



module apb_uart_tb;
  // Clock / reset
  logic PCLK, PCLKG, PRESETn;
  initial
   begin PCLK=0;
    forever #10 PCLK=~PCLK;   // 50 MHz
     end
  assign PCLKG = PCLK; // ungated
  initial 
  begin 
    PRESETn=0;
     #500
     PRESETn=1;
      end

  // Interfaces
  apb_if  apb_vif (PCLK, PRESETn);
  uart_if uart_vif(PCLK, PRESETn);

  // DUT-only wires
  wire TXEN, BAUDTICK;
  wire TXINT, RXINT, TXOVRINT, RXOVRINT, UARTINT;

  // DUT instance (matches cmsdk_apb_uart.v)
  cmsdk_apb_uart dut (
    .PCLK     (PCLK),
    .PCLKG    (PCLKG),
    .PRESETn  (PRESETn),

    .PSEL     (apb_vif.PSEL),
    .PADDR    (apb_vif.PADDR),
    .PENABLE  (apb_vif.PENABLE),
    .PWRITE   (apb_vif.PWRITE),
    .PWDATA   (apb_vif.PWDATA),
    .ECOREVNUM(4'h0),
    .PRDATA   (apb_vif.PRDATA),
    .PREADY   (apb_vif.PREADY),
    .PSLVERR  (apb_vif.PSLVERR),

    .RXD      (uart_vif.RXD),
    .TXD      (uart_vif.TXD),
    .TXEN     (TXEN),
    .BAUDTICK (BAUDTICK),

    .TXINT    (TXINT),
    .RXINT    (RXINT),
    .TXOVRINT (TXOVRINT),
    .RXOVRINT (RXOVRINT),
    .UARTINT  (UARTINT)
  );

  // Hook DUT outputs to uart_if
  assign uart_vif.TXEN     = TXEN;
  assign uart_vif.BAUDTICK = BAUDTICK;

  // UVM config & run
  initial begin
    uvm_config_db#(virtual apb_if) ::set(null, "*",  "vif", apb_vif);
    uvm_config_db#(virtual uart_if)::set(null, "*", "vif", uart_vif);
    run_test();
  end
  initial begin
  #1ms;
  `uvm_fatal("TIMEOUT", "Simulation timed out")

end
endmodule

