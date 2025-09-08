package apb_uart_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // ---------------------------------------------------------
  // Localparams (APB UART Register Map)
  // ---------------------------------------------------------
  localparam ADDR_DATA    = 10'h000; // 0x00
  localparam ADDR_STATUS  = 10'h004; // 0x04
  localparam ADDR_CTRL    = 10'h008; // 0x08
  localparam ADDR_INTSTAT = 10'h00C; // 0x0C
  localparam ADDR_BAUDDIV = 10'h010; // 0x10

  // ---------------------------------------------------------
  // APB Agent (Seq Item → Sequencer → Driver → Monitor → Agent)
  // ---------------------------------------------------------
  `include "apb_item.sv"
  `include "apb_sequencer.sv"
  `include "apb_driver.sv"
  `include "apb_monitor.sv"
  `include "apb_agent.sv"

  // ---------------------------------------------------------
  // UART Agent
  // ---------------------------------------------------------
  `include "uart_item.sv"
  `include "uart_sequencer.sv"
  `include "uart_driver.sv"
  `include "uart_monitor.sv"
  `include "uart_agent.sv"

  // ---------------------------------------------------------
  // Scoreboard & Predictor
  // ---------------------------------------------------------
  `include "apb_uart_scoreboard.sv"
  `include "apb_predictor.sv"


  // ---------------------------------------------------------
  // Environment
  // ---------------------------------------------------------
  `include "apb_uart_env.sv"

  // ---------------------------------------------------------
  // Sequences
  // ---------------------------------------------------------
  `include "apb_write_seq.sv"
  `include "apb_read_seq.sv"
  `include "uart_inject_seq.sv"
  // add more sequences as needed

  // ---------------------------------------------------------
  // Tests
  // ---------------------------------------------------------
`include "../tests/apb_uart_test.sv"
`include "../tests/apb_uart_single_byte_test.sv"
`include "../tests/apb_uart_soft_reset.sv"
`include "../tests/uart_rx_only_test.sv"
`include "../tests/uart_tx_only_test.sv"
`include "../tests/uart_baud_change_idle_test.sv"
`include "../tests/uart_baud_change_tx_test.sv"
`include "../tests/uart_baud_invalid_test.sv"
`include "../tests/uart_baud_valid_test.sv"
`include "../tests/uart_baud_write_test.sv"
`include "../tests/uart_rxint_trigger_test.sv"
`include "../tests/uart_txint_trigger_test.sv"
`include "../tests/uart_interrupt_enable_disable_test.sv"
`include "../tests/uart_intclear_test.sv"
`include "../tests/uart_intclear_selective_test.sv"
`include "../tests/uart_status_read_test.sv"
`include "../tests/uart_rx_overrun_test.sv"
`include "../tests/uart_rx_overrun_int_test.sv"
`include "../tests/uart_tx_overrun_test.sv"
`include "../tests/uart_illegal_fsm_test.sv"
`include "../tests/uart_hs_test_mode_test.sv"
`include "../tests/uart_rx_read_buffer_test.sv"

endpackage
