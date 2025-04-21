`include "base_test.sv"

program program_test (
    memory_if vif
);

  base_test test;

  initial begin
    test = new(vif.tb, vif.tb_mon_in, vif.tb_mon_out);
    test.run();
    $display("[Program] Simulation finished at time=%0t", $time);
  end

endprogram
