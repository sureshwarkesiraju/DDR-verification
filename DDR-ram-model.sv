module ddr_memory_rtl #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32,
    parameter MEM_SIZE   = 16
) (
    input  logic                  clk,
    input  logic                  reset,
    input  logic                  wr,       // Write enable
    input  logic                  rd,       // Read enable
    input  logic [ADDR_WIDTH-1:0] addr,     // Address input
    input  logic [DATA_WIDTH-1:0] wdata,    // Write data
    output logic [DATA_WIDTH-1:0] rdata,    // Read data (tri-state capable)
    output logic                  response
);

  // Internal memory
  logic [DATA_WIDTH-1:0] mem[0:MEM_SIZE-1];
  logic [DATA_WIDTH-1:0] data_out;
  logic out_enable;

  // Tri-state control for rdata
  assign rdata = out_enable ? data_out : 'bz;

  // Synchronous write with async reset
  // // Code your design here

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      for (int i = 0; i < MEM_SIZE; i++) mem[i] <= '0;
      response <= 0;
    end else if (wr) begin
      mem[addr] <= wdata;
      response  <= 1;
    end else begin
      response <= 0;
    end
  end

  // Synchronous read logic
  always_ff @(posedge clk) begin
    if (rd) begin
      data_out   <= mem[addr];
      out_enable <= 1;
    end else begin
      out_enable <= 0;
    end
  end

endmodule

