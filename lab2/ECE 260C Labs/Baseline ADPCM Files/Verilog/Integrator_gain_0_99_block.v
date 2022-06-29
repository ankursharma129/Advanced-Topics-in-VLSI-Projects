// -------------------------------------------------------------
// 
// File Name: Piplined_encoder\adpcm_precision_study\Integrator_gain_0_99_block.v
// Created: 2022-04-30 14:10:34
// 
// Generated by MATLAB 9.11 and HDL Coder 3.19
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: Integrator_gain_0_99_block
// Source Path: adpcm_precision_study/ADPCM_ECD/adpcm encoder2/ADPCM Decoder/Integrator -- gain = 0.99
// Hierarchy Level: 3
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module Integrator_gain_0_99_block
          (clk,
           reset,
           enb,
           StepSize,
           LoopGain,
           Out1);


  input   clk;
  input   reset;
  input   enb;
  input   signed [19:0] StepSize;  // sfix20_En16
  input   signed [27:0] LoopGain;  // sfix28_En24
  output  signed [19:0] Out1;  // sfix20_En16


  wire signed [27:0] Data_Type_Conversion_out1;  // sfix28_En24
  wire signed [27:0] Product_out1;  // sfix28_En24
  wire signed [28:0] Sum2_add_cast;  // sfix29_En24
  wire signed [28:0] Sum2_add_cast_1;  // sfix29_En24
  wire signed [28:0] Sum2_add_temp;  // sfix29_En24
  wire signed [27:0] Sum2_out1;  // sfix28_En24
  reg signed [27:0] Delay_out1;  // sfix28_En24
  wire signed [55:0] Product_mul_temp;  // sfix56_En48
  wire signed [19:0] Data_Type_Conversion1_out1;  // sfix20_En16


  assign Data_Type_Conversion_out1 = {StepSize, 8'b00000000};



  assign Sum2_add_cast = {Product_out1[27], Product_out1};
  assign Sum2_add_cast_1 = {Data_Type_Conversion_out1[27], Data_Type_Conversion_out1};
  assign Sum2_add_temp = Sum2_add_cast + Sum2_add_cast_1;
  assign Sum2_out1 = ((Sum2_add_temp[28] == 1'b0) && (Sum2_add_temp[27] != 1'b0) ? 28'sb0111111111111111111111111111 :
              ((Sum2_add_temp[28] == 1'b1) && (Sum2_add_temp[27] != 1'b1) ? 28'sb1000000000000000000000000000 :
              $signed(Sum2_add_temp[27:0])));



  always @(posedge clk or posedge reset)
    begin : Delay_process
      if (reset == 1'b1) begin
        Delay_out1 <= 28'sb0000000000000000000000000000;
      end
      else begin
        if (enb) begin
          Delay_out1 <= Sum2_out1;
        end
      end
    end



  assign Product_mul_temp = Delay_out1 * LoopGain;
  assign Product_out1 = Product_mul_temp[51:24] + $signed({1'b0, Product_mul_temp[23] & (Product_mul_temp[24] | (|Product_mul_temp[22:0]))});



  assign Data_Type_Conversion1_out1 = Product_out1[27:8] + $signed({1'b0, Product_out1[7] & (Product_out1[8] | (|Product_out1[6:0]))});



  assign Out1 = Data_Type_Conversion1_out1;

endmodule  // Integrator_gain_0_99_block

