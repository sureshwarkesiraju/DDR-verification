interface memory_if (
    input logic clk
);

  parameter ADDR_WIDTH = 4;
  parameter DATA_WIDTH = 32;
  parameter MEM_SIZE = 16;

  logic reset;
  logic wr;
  logic rd;
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] wdata;
  logic [DATA_WIDTH-1:0] rdata;
  logic slv_rsp;

  // Clocking blocks for testbench
  clocking cb @(posedge clk);
    output wr, rd;
    output wdata, addr;
    input rdata;
  endclocking

  clocking cb_mon_in @(posedge clk);
    input wr, rd;
    input wdata, addr;
  endclocking

  clocking cb_mon_out @(posedge clk);
    input rdata;
    input wr, rd;
    input addr;
  endclocking

  // Modports
  modport tb(clocking cb, output reset, input slv_rsp);
  modport tb_mon_in(clocking cb_mon_in);
  modport tb_mon_out(clocking cb_mon_out);

endinterface
