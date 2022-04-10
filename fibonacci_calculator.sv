module fibonacci_calculator (
  input  [4:0] input_s ,
  input  reset ,
  input  begin_fibo ,
  input  clk ,
  output logic done ,
  output logic[27:0] fibo_out) ;

  logic [27:0] curr_num;
  logic [27:0] next_num;
  logic [4:0] input_r;
  
  always_ff @(posedge clk)
    begin
      if (reset)
        begin
          curr_num<=28'h0;
          next_num<=28'h1;
        end
      else if(input_r>2)
        begin
          curr_num<=next_num;
          next_num<=fibo_out;
          input_r<=input_r-1;
        end
      else if(begin_fibo & !reset)
        begin
        input_r<=input_s;
          done<=1'b0;
        end
      else if(input_r<=2 & !done)
        done<=1'b1;
      else if(done)
        done<=1'b0;
    end
  
  
  assign fibo_out = curr_num + next_num;

endmodule