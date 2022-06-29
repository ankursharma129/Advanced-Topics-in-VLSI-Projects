`include "decryptor_pkg.sv"
`include "decryptor_bfm.sv"


module top;
  import uvm_pkg::*;
  import decryptor_pkg::*;///need to add
   
  
  decryptor_bfm bfm();
  
//   tester tester_h(bfm);
//   scoreboard scoreboard_h(bfm);
  
  top_level_4_260 dut(
  .clk(bfm.clk), 
    .init(bfm.init), 
  .wr_en(bfm.wr_en),
  .raddr(bfm.raddr), 
  .waddr(bfm.waddr),
  .data_in(bfm.data_in),
  .data_out(bfm.data_out),             
    .done(bfm.done))       ;          // your top level design goes here 

  

   

   initial begin
//      uvm_config_db#(virtual decryptor_bfm)::set(null,"decryptor_bfm",bfm);
    $dumpfile("dump.vcd");
    $dumpvars;
    uvm_resource_db#(virtual decryptor_bfm)::set
    (.scope("ifs"), .name("decryptor_bfm"), .val(bfm));
     run_test("decryptor_test");
   end

endmodule