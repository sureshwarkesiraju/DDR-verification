`include "environment.sv"

class base_test;

  bit                          [15:0] no_of_pkts;
  virtual memory_if.tb                vif;
  virtual memory_if.tb_mon_in         vif_mon_in;
  virtual memory_if.tb_mon_out        vif_mon_out;

  environment                         env;

  function new(virtual memory_if.tb vif, virtual memory_if.tb_mon_in vif_mon_in,
               virtual memory_if.tb_mon_out vif_mon_out);
    this.vif         = vif;
    this.vif_mon_in  = vif_mon_in;
    this.vif_mon_out = vif_mon_out;
  endfunction

  function void build();
    env = new(vif, vif_mon_in, vif_mon_out, no_of_pkts);
    env.build();
  endfunction

  task run();
    $display("[Testcase] run started @ %0t", $time);
    no_of_pkts = 70;
    build();
    env.run();
    $display("[Testcase] run ended @ %0t", $time);
  endtask

endclass
