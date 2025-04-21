`include "memory_if.sv"
`include "ddr_memory_rtl.sv"
`include "program_test.sv"

module top;

  parameter ADDR_WIDTH = 4;
  parameter DATA_WIDTH = 32;
  parameter MEM_SIZE = 16;

  logic clk;

  // Clock generation (20ns period)
  initial clk = 0;
  always #10 clk = ~clk;

  // Instantiate interface
  memory_if mem_if (clk);

  // Instantiate DUT
  ddr_memory_rtl #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH),
      .MEM_SIZE  (MEM_SIZE)
  ) dut_inst (
      .clk     (clk),
      .reset   (mem_if.reset),
      .wr      (mem_if.wr),
      .rd      (mem_if.rd),
      .addr    (mem_if.addr),
      .wdata   (mem_if.wdata),
      .rdata   (mem_if.rdata),
      .response(mem_if.slv_rsp)
  );

  // Start program block
  program_test ptest (mem_if);

endmodule


