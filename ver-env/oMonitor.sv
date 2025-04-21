`include "packet.sv"

class oMonitor;

  string name;
  bit [15:0] no_of_pkts_recvd;
  packet pkt;

  virtual memory_if.tb_mon_out vif;
  mailbox #(packet) mbx;

  function new(mailbox#(packet) mbx_in, virtual memory_if.tb_mon_out vif_in,
               string name = "oMonitor");
    this.mbx  = mbx_in;
    this.vif  = vif_in;
    this.name = name;
  endfunction

  task run();
    $display("[%s] run started at time=%0t", name, $time);

    while (1) begin
      @(vif.cb_mon_out.rdata);

      // Skip invalid read values
      if (vif.cb_mon_out.rdata === 'z || vif.cb_mon_out.rdata === 'x) continue;

      pkt = new;
      pkt.addr = vif.cb_mon_out.addr;
      pkt.data = vif.cb_mon_out.rdata;

      mbx.put(pkt);
      no_of_pkts_recvd++;

      pkt.print();
      $display("[%s] Sent packet %0d to scoreboard at time=%0t", name, no_of_pkts_recvd, $time);
    end
  endtask

  function void report();
    $display("[%s] Report: total_packets_received = %0d", name, no_of_pkts_recvd);
  endfunction

endclass
