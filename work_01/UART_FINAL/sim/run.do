# ================================================================
# run.do - QuestaSim regression script (flexible: single/multiple/all tests)
# ================================================================

# -------------------------------
# Clean previous simulation
# -------------------------------
if {[file exists work]} {
    vdel -all
}
vlib work
vmap work work

# -------------------------------
# Compile Design
# -------------------------------
vlog ../design/cmsdk_apb_uart.v
vlog -sv ../uvm_tb/interface.sv
vlog ../uvm_tb/apb_uart_pkg.sv
vlog ../sim/top.sv

# -------------------------------
# Create logs directory
# -------------------------------
file mkdir logs

# -------------------------------
# Default list of all tests
# -------------------------------
set all_tests {
    apb_uart_test
    apb_uart_single_byte_test
    apb_uart_soft_reset_test
    uart_rx_only_test
    uart_tx_only_test
    uart_baud_change_idle_test
    uart_baud_change_tx_test
    uart_baud_invalid_test
    uart_baud_valid_test
    uart_baud_write_test
    uart_rxint_trigger_test
    uart_txint_trigger_test
    uart_interrupt_enable_disable_test
    uart_intclear_test
    uart_intclear_selective_test
    uart_status_read_test
    uart_rx_overrun_test
    uart_rx_overrun_int_test
    uart_tx_overrun_test
    uart_illegal_fsm_test
    uart_hs_test_mode_test
    uart_rx_read_buffer_test
}

# -------------------------------
# Check if user provided TESTS_TO_RUN
# -------------------------------
if {[info exists TESTS_TO_RUN]} {
    set tests $TESTS_TO_RUN
} else {
    set tests $all_tests
}

# -------------------------------
# Run each test
# -------------------------------
array set results {}

foreach t $tests {
    puts "============================================================"
    puts " Running test: $t "
    puts "============================================================"

    set logfile logs/$t.log

    # Run simulation
    set result [catch { exec vsim -c -quiet -l $logfile -do "run -all; quit -f" apb_uart_tb +UVM_TESTNAME=$t }]

    # Print log to console
    if {[file exists $logfile]} {
        puts "---------------- Log for $t ----------------"
        set f [open $logfile r]
        puts [read $f]
        close $f
        puts "-------------------------------------------"
    } else {
        puts "No log file generated for $t"
    }

    # Record PASS/FAIL
    if {$result == 0} {
        set results($t) PASS
    } else {
        set results($t) FAIL
    }
}

# -------------------------------
# Regression Summary
# -------------------------------
puts ""
puts "================ Regression Summary ================"
foreach t $tests {
    if {[info exists results($t)]} {
        puts "$t : $results($t)"
    } else {
        puts "$t : NOT RUN"
    }
}
puts "===================================================="
