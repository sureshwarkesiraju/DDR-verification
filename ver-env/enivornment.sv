`include "packet.sv"
`include "generator.sv"
`include "driver.sv"
`include "iMonitor.sv"
`include "oMonitor.sv"
`include "scoreboard.sv"
`include "coverage.sv"

class environment;

  bit                          [15:0] no_of_pkts;

  mailbox #(packet)                   gen_drv_mbox;
  mailbox #(packet)                   mon_in_scb_mbox;
  mailbox #(packet)                   mon_out_scb_mbox;

  virtual memory_if.tb                vif;
  virtual memory_if.tb_mon_in         vif_mon_in;
  virtual memory_if.tb_mon_out        vif_mon_out;

  generator                           gen;
  driver                              drvr;
  iMonitor                            mon_in;
  oMonitor                            mon_out;
  scoreboard                          scb;
  coverage                            cov;

  function new(virtual memory_if.tb vif, virtual memory_if.tb_mon_in vif_mon_in,
               virtual memory_if.tb_mon_out vif_mon_out, input bit [15:0] no_of_pkts);
    this.vif         = vif;
    this.vif_mon_in  = vif_mon_in;
    this.vif_mon_out = vif_mon_out;
    this.no_of_pkts  = no_of_pkts;
  endfunction
  function void build();
    $display("[Environment] build started at time %0t", $time);
    gen_drv_mbox     = new(1);
    mon_in_scb_mbox  = new;
    mon_out_scb_mbox = new;

    gen              = new(gen_drv_mbox, no_of_pkts);
    drvr             = new(gen_drv_mbox, vif);
    mon_in           = new(mon_in_scb_mbox, vif_mon_in, "iMonitor");
    mon_out          = new(mon_out_scb_mbox, vif_mon_out, "oMonitor");
    scb              = new(mon_in_scb_mbox, mon_out_scb_mbox);
    cov              = new(mon_in_scb_mbox);

    $display("[Environment] build completed at time %0t", $time);
  endfunction

  task run();
    $display("[Environment] run started at time %0t", $time);
    fork
      gen.run();
      drvr.run();
      mon_in.run();
      mon_out.run();
      scb.run();
      cov.run();
    join_any

    wait (scb.total_pkts_recvd == no_of_pkts);
    repeat (10) @(vif.cb);

    report();
    $display("[Environment] run ended at time %0t", $time);
  endtask

  function void report();
    $display("\n[Environment] ********** Report **********");
    gen.report();
    drvr.report();
    mon_in.report();
    mon_out.report();
    scb.report();
    cov.report();

    if (scb.m_mismatches == 0 && (no_of_pkts == scb.total_pkts_recvd)) begin
      $display("*********** TEST PASSED ************");
      $display("***** Functional Coverage = %0f *****", cov.coverage_score);
    end else begin
      $display("*********** TEST FAILED ************");
    end
    $display("************************************\n");
  endfunction

endclass
