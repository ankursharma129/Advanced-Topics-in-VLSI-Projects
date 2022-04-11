module fibonacci_calculator (input logic clk, reset,
                             input logic [4:0] input_s,
                             input logic begin_fibo,
                            output logic [28:0] fibo_out,
                            output logic done);

  enum logic [1:0] {RESET=2'b00, BEGIN=2'b01, COMPUTE=2'b10, DONE=2'b11} status;

  logic  [4:0] input_r;
  logic [28:0] curr_num, next_num;

  always_ff @(posedge clk)
  begin
    if (reset) begin
      status <= RESET;
      done <= 0;
    end else if (!reset & begin_fibo)
      status<=BEGIN;
    else
      case (status)
        RESET:
          begin
            curr_num <= 0;
            next_num <= 1;
          end
        BEGIN:
          begin
            input_r <= input_s;
            status <= COMPUTE;
          end
        COMPUTE:
          if (input_r) begin
            input_r <= input_r - 1;
            curr_num <= curr_num + next_num;
            next_num <= curr_num;
          end else begin
            status <= DONE;
            done <= 1;
            fibo_out <= curr_num;
          end 
        DONE:
          status <= RESET;
      endcase
  end
endmodule