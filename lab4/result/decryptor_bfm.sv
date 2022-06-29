interface decryptor_bfm;

  logic       clk               ;
  logic       init              ;  
  logic       wr_en             ;     
  logic [7:0] raddr             ,
              waddr             ,
              data_in           ;
  wire  [7:0] data_out          ;
  wire        done              ;        

  int ct                        ;
    
  
  initial begin: decryptor_loop
    clk   = 'b0;
    
    init  = 'b1;

    wr_en = 'b0;

  
  end: decryptor_loop
  
  always begin							 // continuous loop
  #5ns clk = 1;							 // clock tick
  #5ns clk = 0;							 // clock tock
end										 // continue
  
  endinterface