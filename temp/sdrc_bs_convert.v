`include "sdrc_define.v"
module sdrc_bs_convert (
                    clk                 ,
                    reset_n             ,
                    sdr_width           ,
 
        /* Control Signal from xfr ctrl */
                    x2a_rdstart         ,
                    x2a_wrstart         ,
                    x2a_rdlast          ,
                    x2a_wrlast          ,
                    x2a_rddt            ,
                    x2a_rdok            ,
                    a2x_wrdt            ,
                    a2x_wren_n          ,
                    x2a_wrnext          ,
 
   /*  Control Signal from/to to application i/f  */
                    app_wr_data         ,
                    app_wr_en_n         ,
                    app_wr_next         ,
                    app_last_wr         ,
                    app_rd_data         ,
                    app_rd_valid        ,
		    app_last_rd
		);
 
 
parameter  APP_AW   = 30;  // Application Address Width
parameter  APP_DW   = 32;  // Application Data Width 
parameter  APP_BW   = 4;   // Application Byte Width
 
parameter  SDR_DW   = 16;  // SDR Data Width 
parameter  SDR_BW   = 2;   // SDR Byte Width
 
input                    clk              ;
input                    reset_n          ;
input [1:0]              sdr_width        ; // 2'b00 - 32 Bit SDR, 2'b01 - 16 Bit SDR, 2'b1x - 8 Bit
 
/* Control Signal from xfr ctrl Read Transaction*/
input                    x2a_rdstart      ; // read start indication
input                    x2a_rdlast       ; //  read last burst access
input [SDR_DW-1:0]       x2a_rddt         ;
input                    x2a_rdok         ;
 
/* Control Signal from xfr ctrl Write Transaction*/
input                    x2a_wrstart      ; // writ start indication
input                    x2a_wrlast       ; // write last transfer
input                    x2a_wrnext       ;
output [SDR_DW-1:0]      a2x_wrdt         ;
output [SDR_BW-1:0]      a2x_wren_n       ;
 
// Application Write Transaction
input  [APP_DW-1:0]      app_wr_data      ;
input  [APP_BW-1:0]      app_wr_en_n      ;
output                   app_wr_next      ;
output                   app_last_wr      ; // Indicate last Write Transfer for a given burst size
 
// Application Read Transaction
output [APP_DW-1:0]      app_rd_data      ;
output                   app_rd_valid     ;
output                   app_last_rd      ; // Indicate last Read Transfer for a given burst size
 
//----------------------------------------------
// Local Decleration
// ----------------------------------------
 
reg [APP_DW-1:0]         app_rd_data      ;
reg                      app_rd_valid     ;
reg [SDR_DW-1:0]         a2x_wrdt         ;
reg [SDR_BW-1:0]         a2x_wren_n       ;
reg                      app_wr_next      ;
 
reg [23:0]               saved_rd_data    ;
reg [1:0]                rd_xfr_count     ;
reg [1:0]                wr_xfr_count     ;
 
 
assign  app_last_wr = x2a_wrlast;
assign  app_last_rd = x2a_rdlast;
 
always @(*) begin
        if(sdr_width == 2'b00) // 32 Bit SDR Mode
          begin
            a2x_wrdt             = app_wr_data;
            a2x_wren_n           = app_wr_en_n;
            app_wr_next          = x2a_wrnext;
            app_rd_data          = x2a_rddt;
            app_rd_valid         = x2a_rdok;
          end
        else if(sdr_width == 2'b01) // 16 Bit SDR Mode
        begin
           // Changed the address and length to match the 16 bit SDR Mode
            app_wr_next          = (x2a_wrnext & wr_xfr_count[0]);
            app_rd_valid         = (x2a_rdok & rd_xfr_count[0]);
            if(wr_xfr_count[0] == 1'b1)
              begin
                a2x_wren_n      = app_wr_en_n[3:2];
                a2x_wrdt        = app_wr_data[31:16];
              end
            else
              begin
                a2x_wren_n      = app_wr_en_n[1:0];
                a2x_wrdt        = app_wr_data[15:0];
              end
 
            app_rd_data = {x2a_rddt,saved_rd_data[15:0]};
        end else  // 8 Bit SDR Mode
        begin
           // Changed the address and length to match the 16 bit SDR Mode
            app_wr_next         = (x2a_wrnext & (wr_xfr_count[1:0]== 2'b11));
            app_rd_valid        = (x2a_rdok &   (rd_xfr_count[1:0]== 2'b11));
            if(wr_xfr_count[1:0] == 2'b11)
            begin
                a2x_wren_n      = app_wr_en_n[3];
                a2x_wrdt        = app_wr_data[31:24];
            end
            else if(wr_xfr_count[1:0] == 2'b10)
            begin
                a2x_wren_n      = app_wr_en_n[2];
                a2x_wrdt        = app_wr_data[23:16];
            end
            else if(wr_xfr_count[1:0] == 2'b01)
            begin
                a2x_wren_n      = app_wr_en_n[1];
                a2x_wrdt        = app_wr_data[15:8];
            end
            else begin
                a2x_wren_n      = app_wr_en_n[0];
                a2x_wrdt        = app_wr_data[7:0];
            end
 
            app_rd_data         = {x2a_rddt,saved_rd_data[23:0]};
          end
     end
 
 
 
always @(posedge clk)
  begin
    if(!reset_n)
      begin
        rd_xfr_count    <= 8'b0;
        wr_xfr_count    <= 8'b0;
	saved_rd_data   <= 24'h0;
      end
    else begin
 
	// During Write Phase
        if(x2a_wrlast) begin
           wr_xfr_count    <= 0;
        end
        else if(x2a_wrnext) begin
           wr_xfr_count <= wr_xfr_count + 1'b1;
        end
 
	// During Read Phase
        if(x2a_rdlast) begin
           rd_xfr_count    <= 0;
        end
        else if(x2a_rdok) begin
           rd_xfr_count   <= rd_xfr_count + 1'b1;
	end
 
	// Save Previous Data
        if(x2a_rdok) begin
	   if(sdr_width == 2'b01) // 16 Bit SDR Mode
	      saved_rd_data[15:0]  <= x2a_rddt;
            else begin// 8 bit SDR Mode - 
	       if(rd_xfr_count[1:0] == 2'b00)      saved_rd_data[7:0]   <= x2a_rddt[7:0];
	       else if(rd_xfr_count[1:0] == 2'b01) saved_rd_data[15:8]  <= x2a_rddt[7:0];
	       else if(rd_xfr_count[1:0] == 2'b10) saved_rd_data[23:16] <= x2a_rddt[7:0];
	    end
        end
    end
end
 
endmodule // sdr_bs_convert
 