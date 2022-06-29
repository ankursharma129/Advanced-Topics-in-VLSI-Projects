// -------------------------------------------------------------
// 
// File Name: adpcm\adpcm_precision_study\Step_Size_Adaptor1_block.v
// Created: 2022-04-30 23:31:54
// 
// Generated by MATLAB 9.10 and HDL Coder 3.18
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: Step_Size_Adaptor1_block
// Source Path: adpcm_precision_study/adpcm/adpcm encoder2/ADPCM Decoder/Step Size Adaptor1
// Hierarchy Level: 3
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module Step_Size_Adaptor1_block
          (clk,
           reset,
           enb,
           in,
           out);


  input   clk;
  input   reset;
  input   enb;
  input   signed [15:0] in;  // sfix16_En12
  output  signed [15:0] out;  // sfix16_En12


  wire current_previous_out1;
  wire Delay1_ctrl_const_out;
  reg  Delay1_ctrl_delay_out;
  wire signed [15:0] Delay1_Initial_Val_out;  // sfix16_En12
  wire signed [15:0] Saturation_out1;  // sfix16_En12
  reg signed [15:0] Delay1_out;  // sfix16_En12
  wire signed [15:0] Delay1_out1;  // sfix16_En12
  wire signed [15:0] Subsystem_out1;  // sfix16_En12
  wire signed [31:0] Product_mul_temp;  // sfix32_En24
  wire signed [15:0] Product_out1;  // sfix16_En12

  // If current = previous, double step size
  // else halve step size
  // 
  // current = previous?
  // 
  // *2 or /2
  // 
  // limit step range 
  // to 0.01 to 0.5


  current_previous_block u_current_previous (.clk(clk),
                                             .reset(reset),
                                             .enb(enb),
                                             .In1(in),  // sfix16_En12
                                             .Out1(current_previous_out1)
                                             );

  assign Delay1_ctrl_const_out = 1'b1;



  always @(posedge clk or posedge reset)
    begin : Delay1_ctrl_delay_process
      if (reset == 1'b1) begin
        Delay1_ctrl_delay_out <= 1'b0;
      end
      else begin
        if (enb) begin
          Delay1_ctrl_delay_out <= Delay1_ctrl_const_out;
        end
      end
    end



  assign Delay1_Initial_Val_out = 16'sb0000000110100000;



  always @(posedge clk or posedge reset)
    begin : Delay1_process
      if (reset == 1'b1) begin
        Delay1_out <= 16'sb0000000000000000;
      end
      else begin
        if (enb) begin
          Delay1_out <= Saturation_out1;
        end
      end
    end



  assign Delay1_out1 = (Delay1_ctrl_delay_out == 1'b0 ? Delay1_Initial_Val_out :
              Delay1_out);



  Subsystem_block u_Subsystem (.In1(current_previous_out1),
                               .In2(Delay1_out1),  // sfix16_En12
                               .Out1(Subsystem_out1)  // sfix16_En12
                               );

  assign Saturation_out1 = (Subsystem_out1 > 16'sb0000100000000000 ? 16'sb0000100000000000 :
              (Subsystem_out1 < 16'sb0000000000010101 ? 16'sb0000000000010101 :
              Subsystem_out1));



  assign Product_mul_temp = in * Saturation_out1;
  assign Product_out1 = (((Product_mul_temp[31] == 1'b0) && (Product_mul_temp[30:27] != 4'b0000)) || ((Product_mul_temp[31] == 1'b0) && (Product_mul_temp[27:12] == 16'sb0111111111111111)) ? 16'sb0111111111111111 :
              ((Product_mul_temp[31] == 1'b1) && (Product_mul_temp[30:27] != 4'b1111) ? 16'sb1000000000000000 :
              Product_mul_temp[27:12] + $signed({1'b0, Product_mul_temp[11] & (Product_mul_temp[12] | (|Product_mul_temp[10:0]))})));



  assign out = Product_out1;

endmodule  // Step_Size_Adaptor1_block
