`include "packet.sv"

class coverage;

  packet pkt;
  real coverage_score;
  mailbox #(packet) mbx;

  covergroup fcov with function sample (packet pkt);
    coverpoint pkt.addr;  // Cover all addresses accessed
  endgroup

  function new(input mailbox#(packet) mbx_arg);
    this.mbx = mbx_arg;
    fcov = new;
  endfunction

  virtual task run();
    $display("[Coverage] run started at time=%0t", $time);
    while (1) begin
      @(mbx.num);  // Wait until mailbox has at least one packet
      mbx.peek(pkt);
      fcov.sample(pkt);
      coverage_score = fcov.get_coverage();
      $display("[FCOV] Coverage = %0f%%", coverage_score);
    end
  endtask

  function void report();
    $display("********* Functional Coverage Report **********");
    $display("Coverage Score = %0f%%", coverage_score);
    $display("***********************************************");
  endfunction

endclass
