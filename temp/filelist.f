# ------------------------------
# Compile-time defines
# ------------------------------
+define+S50
+define+VERBOSE
+incdir+./rtl_design/core
+incdir+./verif
+incdir+./tb
+incdir+./model

# ------------------------------
# Testbench top
# ------------------------------


# ------------------------------
# SDRAM Models
# ------------------------------
//./model/mt48lc2m32b2.v
//./model/mt48lc8m8a2.v

# ------------------------------
# RTL Design
# ------------------------------
./rtl_design/core/sdrc_top.v
./rtl_design/core/wb2sdrc.v
./rtl_design/core/async_fifo.v
./rtl_design/core/sdrc_core.v
./rtl_design/core/sdrc_bank_ctl.v
./rtl_design/core/sdrc_bank_fsm.v
./rtl_design/core/sdrc_bs_convert.v
./rtl_design/core/sdrc_req_gen.v
./rtl_design/core/sdrc_xfr_ctl.v

# ------------------------------
# Verification Environment (UVM)
#
./tb/top.sv
# ------------------------------
./wb_if.sv



        #      sdram/  
        #├── filelist.f  
        #├── rtl_design/  
        #│   └── core/  
        #│       ├── sdrc_core.v  
        #│       ├── sdrc_bank_ctl.v  
        #│       ├── ... (other .v files)  
        #├── tb/  
        #│   └── tb_top.sv  // top.sv for uvm tb 
        #└── model/  
        #    ├── IS42VM16400K.v  // not included
        #    ├── mt48lc2m32b2.v  
        #    └── mt48lc8m8a2.v  
        #-----verif
        #
