`ifndef PACKET_SV
`define PACKET_SV


`define A_WIDTH 4
`define D_WIDTH 32

typedef enum {
  IDLE,
  STIMULUS,
  RESET
} pkt_type_t;

class packet;
  string name = "Packet";

  rand bit [`A_WIDTH-1:0] addr;
  rand bit [`D_WIDTH-1:0] data;
  rand bit wr;
  pkt_type_t kind;

  bit slv_rsp;
  bit [3:0] reset_cycles;
  bit [3:0] prev_addr;
  bit [31:0] prev_data;

  constraint valid {
    addr inside {[0 : 15]};
    data inside {[10 : 9999]};
    data != prev_data;
    addr != prev_addr;
  }
  function void post_randomize();
    prev_addr = addr;
    prev_data = data;
  endfunction

  extern function new(string name = "Packet");
  extern function void print();
  extern function void copy(packet rhs);
  extern function bit compare(packet rhs);
endclass

function packet::new(string name = "Packet");
  this.name = name;
endfunction

function void packet::print();
  $display("[Packet] addr=%0d data=%0d time=%0t", addr, data, $time);
endfunction

function void packet::copy(packet rhs);
  if (rhs == null) begin
    $display("[Packet] ERROR: Null object passed to copy()");
    return;
  end
  this.addr = rhs.addr;
  this.data = rhs.data;
endfunction

function bit packet::compare(packet rhs);
  if (rhs == null) begin
    $display("[Packet] ERROR: Null object passed to compare()");
    return 0;
  end
  return (this.addr == rhs.addr) && (this.data == rhs.data);
endfunction
`endif
