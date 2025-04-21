`include "packet.sv"

class driver;

  packet pkt;
  mailbox #(packet) mbx;
  virtual memory_if.tb vif;

  bit [15:0] no_of_pkts_recvd;

  function new(mailbox#(packet) mbx_in, virtual memory_if.tb vif_in);
    this.mbx = mbx_in;
    this.vif = vif_in;
  endfunction

  task run();
    $display("[Driver] run started at time=%0t", $time);
    while (1) begin
      mbx.get(pkt);
      no_of_pkts_recvd++;
      $display("[Driver] Received %0s packet %0d from generator at time=%0t", pkt.kind.name(),
               no_of_pkts_recvd, $time);
      drive(pkt);
      $display("[Driver] Done with %0s packet %0d at time=%0t", pkt.kind.name(), no_of_pkts_recvd,
               $time);
    end
  endtask

  task drive(packet pkt);
    case (pkt.kind)
      RESET:    drive_reset(pkt);
      STIMULUS: drive_stimulus(pkt);
      default:  $display("[Driver] ERROR: Unknown packet kind received");
    endcase
  endtask
  task drive_reset(packet pkt);
    $display("[Driver] Driving reset for %0d cycles at time=%0t", pkt.reset_cycles, $time);
    vif.reset <= 1;
    repeat (pkt.reset_cycles) @(vif.cb);
    vif.reset <= 0;
    $display("[Driver] Reset completed at time=%0t", $time);
  endtask

  task drive_stimulus(packet pkt);
    write(pkt);
    read(pkt);
  endtask

  task write(packet pkt);
    @(vif.cb);
    vif.cb.wr    <= 1;
    vif.cb.addr  <= pkt.addr;
    vif.cb.wdata <= pkt.data;
    @(vif.cb);
    vif.cb.wr <= 0;
    $display("[Driver] WRITE: addr=%0d data=%0d @ %0t", pkt.addr, pkt.data, $time);
  endtask
  task read(packet pkt);
    @(vif.cb);
    vif.cb.rd   <= 1;
    vif.cb.addr <= pkt.addr;
    @(vif.cb);
    vif.cb.rd <= 0;
    $display("[Driver] READ: addr=%0d @ %0t", pkt.addr, $time);
  endtask

  function void report(string str = "Driver");
    $display("[%s] Report: total_packets_driven = %0d", str, no_of_pkts_recvd);
  endfunction

endclass
