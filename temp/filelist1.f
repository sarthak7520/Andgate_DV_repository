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
./mt48lc2m32b2.v
./mt48lc8m8a2.v

# ------------------------------
# RTL Design
# ------------------------------
./sdrc_top.v
./wb2sdrc.v
./async_fifo.v
./sdrc_core.v
./sdrc_bank_ctl.v
./sdrc_bank_fsm.v
./sdrc_bs_convert.v
./sdrc_req_gen.v
./sdrc_xfr_ctl.v

# ------------------------------
# Verification Environment (UVM)

//./wb_pkg.sv
./top.sv
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
