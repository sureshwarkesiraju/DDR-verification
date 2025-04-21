`include "packet.sv"

class generator;

  bit [15:0] no_of_pkts;
  packet pkt;
  mailbox #(packet) mbx;

  function new(mailbox#(packet) mbx_in, bit [15:0] gen_pkts_no = 1);
    this.no_of_pkts = gen_pkts_no;
    this.mbx = mbx_in;
  endfunction

  task run();
    bit [15:0] pkt_count = 0;
    packet ref_pkt = new;
    $display("[Generator] run started at time=%0t", $time);

    // First packet = RESET
    pkt = new;
    pkt.kind = RESET;
    pkt.reset_cycles = 2;
    $display("[Generator] Sending %0s packet %0d to driver at time=%0t", pkt.kind.name(),
             pkt_count, $time);
    mbx.put(pkt);
    // Stimulus packets
    repeat (no_of_pkts) begin
      assert (ref_pkt.randomize());
      pkt = new;
      pkt.copy(ref_pkt);
      pkt.kind = STIMULUS;
      mbx.put(pkt);
      pkt_count++;
      $display("[Generator] Sent %0s packet %0d to driver at time=%0t", pkt.kind.name(), pkt_count,
               $time);
    end

    $display("[Generator] run ended at time=%0t", $time);
  endtask

  function void report(string str = "Generator");
    $display("[%s] Report: total_packets_generated = %0d", str, no_of_pkts);
  endfunction

endclass
