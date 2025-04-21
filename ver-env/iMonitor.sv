`include "packet.sv"

class iMonitor;

  string name;
  bit [15:0] no_of_pkts_recvd;
  packet pkt;

  virtual memory_if.tb_mon_in vif;
  mailbox #(packet) mbx;

  function new(mailbox#(packet) mbx_in, virtual memory_if.tb_mon_in vif_in,
               string name = "iMonitor");
    this.mbx  = mbx_in;
    this.vif  = vif_in;
    this.name = name;
  endfunction

  task run();
    bit [15:0] addr;
    $display("[%s] run started at time=%0t", name, $time);
    while (1) begin
      @(vif.cb_mon_in.wdata);  // Triggered on a write

      pkt = new;
      pkt.addr = vif.cb_mon_in.addr;
      pkt.data = vif.cb_mon_in.wdata;

      mbx.put(pkt);

      fork
        begin
          packet temp;
          #0 while (mbx.num >= 1) void'(mbx.try_get(temp));
        end
      join_none
      no_of_pkts_recvd++;
      pkt.print();
      $display("[%s] Sent packet %0d to scoreboard at time=%0t", name, no_of_pkts_recvd, $time);
    end
  endtask

  function void report();
    $display("[%s] Report: total_packets_received = %0d", name, no_of_pkts_recvd);
  endfunction

endclass
