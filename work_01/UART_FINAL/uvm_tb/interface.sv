//------------------------------------------------------------
// Interfaces
//------------------------------------------------------------
interface apb_if(input logic PCLK, input logic PRESETn);
  
  //localparam int ADDR_WIDTH    = 'h12;
  logic        PSEL;
  logic        PENABLE;	
  logic        PWRITE;
  logic [11:2] PADDR;    // 10-bit aligned address
  logic [31:0] PWDATA;
  logic [31:0] PRDATA;
  logic        PREADY;
  logic        PSLVERR;
endinterface

interface uart_if(input logic PCLK, input logic PRESETn);
  logic RXD;       // input to DUT
  logic TXD;       // output from DUT
  logic TXEN;      // output from DUT
  logic BAUDTICK;  // output from DUT (x16)
endinterface
