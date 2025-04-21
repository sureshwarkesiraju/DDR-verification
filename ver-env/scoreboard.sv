`include "packet.sv"

class scoreboard;

  bit [15:0] total_pkts_recvd;
  packet ref_pkt;
  packet got_pkt;

  mailbox #(packet) mbx_in;  // From input monitor
  mailbox #(packet) mbx_out;  // From output monitor

  bit [15:0] m_matches;
  bit [15:0] m_mismatches;

  function new(mailbox#(packet) mbx_in, mailbox#(packet) mbx_out);
    this.mbx_in  = mbx_in;
    this.mbx_out = mbx_out;
  endfunction

  task run();
    $display("[Scoreboard] run started at time=%0t", $time);
    while (1) begin
      mbx_in.peek(ref_pkt);  // Peek input (ref)
      mbx_out.get(got_pkt);  // Get output (observed)

      total_pkts_recvd++;

      if (ref_pkt.compare(got_pkt)) begin
        m_matches++;
        $display("[Scoreboard] Match: Packet %0d matched at time=%0t", total_pkts_recvd, $time);
      end else begin
        m_mismatches++;
        $display("[Scoreboard] ERROR: Mismatch at time=%0t", $time);
        $display("[Scoreboard] Expected addr=%0d data=%0d | Got addr=%0d data=%0d", ref_pkt.addr,
                 ref_pkt.data, got_pkt.addr, got_pkt.data);
      end
    end
  endtask

  function void report();
    $display("[Scoreboard] Report: Total = %0d | Matches = %0d | Mismatches = %0d",
             total_pkts_recvd, m_matches, m_mismatches);
  endfunction

endclass
