// -------------------------------------------------------------
// 
// File Name: adpcm\adpcm_precision_study\adpcm.v
// Created: 2022-04-30 23:31:54
// 
// Generated by MATLAB 9.10 and HDL Coder 3.18
// 
// 
// -- -------------------------------------------------------------
// -- Rate and Clocking Details
// -- -------------------------------------------------------------
// Model base rate: 1e-05
// Target subsystem base rate: 1e-05
// 
// 
// Clock Enable  Sample Time
// -- -------------------------------------------------------------
// ce_out        1e-05
// -- -------------------------------------------------------------
// 
// 
// Output Signal                 Clock Enable  Sample Time
// -- -------------------------------------------------------------
// Out1                          ce_out        1e-05
// -- -------------------------------------------------------------
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: adpcm
// Source Path: adpcm_precision_study/adpcm
// Hierarchy Level: 0
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module adpcm
          (clk,
           reset,
           clk_enable,
           in1,
           ce_out,
           Out1);


  input   clk;
  input   reset;
  input   clk_enable;
  input   signed [15:0] in1;  // sfix16_En12
  output  ce_out;
  output  signed [15:0] Out1;  // sfix16_En12


  wire signed [1:0] adpcm_encoder2_out1;  // sfix2
  wire signed [15:0] ADPCM_Decoder1_out1;  // sfix16_En12


  adpcm_encoder2 u_adpcm_encoder2 (.clk(clk),
                                   .reset(reset),
                                   .enb(clk_enable),
                                   .in1(in1),  // sfix16_En12
                                   .out1(adpcm_encoder2_out1)  // sfix2
                                   );

  ADPCM_Decoder1 u_ADPCM_Decoder1 (.clk(clk),
                                   .reset(reset),
                                   .enb(clk_enable),
                                   .In1(adpcm_encoder2_out1),  // sfix2
                                   .Out1(ADPCM_Decoder1_out1)  // sfix16_En12
                                   );

  assign Out1 = ADPCM_Decoder1_out1;

  assign ce_out = clk_enable;

endmodule  // adpcm

