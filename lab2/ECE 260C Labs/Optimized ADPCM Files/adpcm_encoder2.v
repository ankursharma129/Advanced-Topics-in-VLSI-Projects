// -------------------------------------------------------------
// 
// File Name: adpcm\adpcm_precision_study\adpcm_encoder2.v
// Created: 2022-04-30 23:31:54
// 
// Generated by MATLAB 9.10 and HDL Coder 3.18
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: adpcm_encoder2
// Source Path: adpcm_precision_study/adpcm/adpcm encoder2
// Hierarchy Level: 1
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module adpcm_encoder2
          (clk,
           reset,
           enb,
           in1,
           out1);


  input   clk;
  input   reset;
  input   enb;
  input   signed [15:0] in1;  // sfix16_En12
  output  signed [1:0] out1;  // sfix2


  reg signed [15:0] Delay2_reg [0:1];  // sfix16 [2]
  wire signed [15:0] Delay2_reg_next [0:1];  // sfix16_En12 [2]
  wire signed [15:0] Delay2_out1;  // sfix16_En12
  wire signed [19:0] IntegratorGain_out1;  // sfix20_En16
  wire signed [15:0] Subsystem_out2;  // sfix16_En12
  wire signed [15:0] ADPCM_Decoder_out1;  // sfix16_En12
  wire signed [31:0] Sum_sub_cast;  // sfix32_En12
  wire signed [31:0] Sum_sub_cast_1;  // sfix32_En12
  wire signed [31:0] Sum_sub_temp;  // sfix32_En12
  wire signed [15:0] Sum_out1;  // sfix16_En12
  wire signed [1:0] Subsystem_out1;  // sfix2
  reg signed [1:0] Delay1_reg [0:1];  // sfix2 [2]
  wire signed [1:0] Delay1_reg_next [0:1];  // sfix2 [2]
  wire signed [1:0] Delay1_out1;  // sfix2

  // Incoming - Reconstructed
  // 
  // Sign of Difference
  // 
  // Restore Fraction (0)
  // 
  // +1, 0, or -1


  always @(posedge clk or posedge reset)
    begin : Delay2_process
      if (reset == 1'b1) begin
        Delay2_reg[0] <= 16'sb0000000000000000;
        Delay2_reg[1] <= 16'sb0000000000000000;
      end
      else begin
        if (enb) begin
          Delay2_reg[0] <= Delay2_reg_next[0];
          Delay2_reg[1] <= Delay2_reg_next[1];
        end
      end
    end

  assign Delay2_out1 = Delay2_reg[1];
  assign Delay2_reg_next[0] = in1;
  assign Delay2_reg_next[1] = Delay2_reg[0];



  assign IntegratorGain_out1 = 20'sb00010000000000000000;



  ADPCM_Decoder u_ADPCM_Decoder (.clk(clk),
                                 .reset(reset),
                                 .enb(enb),
                                 .In1(Subsystem_out2),  // sfix16_En12
                                 .LoopGain(IntegratorGain_out1),  // sfix20_En16
                                 .Out1(ADPCM_Decoder_out1)  // sfix16_En12
                                 );

  assign Sum_sub_cast = {{16{Delay2_out1[15]}}, Delay2_out1};
  assign Sum_sub_cast_1 = {{16{ADPCM_Decoder_out1[15]}}, ADPCM_Decoder_out1};
  assign Sum_sub_temp = Sum_sub_cast - Sum_sub_cast_1;
  assign Sum_out1 = ((Sum_sub_temp[31] == 1'b0) && (Sum_sub_temp[30:15] != 16'b0000000000000000) ? 16'sb0111111111111111 :
              ((Sum_sub_temp[31] == 1'b1) && (Sum_sub_temp[30:15] != 16'b1111111111111111) ? 16'sb1000000000000000 :
              $signed(Sum_sub_temp[15:0])));



  Subsystem_block1 u_Subsystem (.In1(Sum_out1),  // sfix16_En12
                                .Out1(Subsystem_out1),  // sfix2
                                .Out2(Subsystem_out2)  // sfix16_En12
                                );

  always @(posedge clk or posedge reset)
    begin : Delay1_process
      if (reset == 1'b1) begin
        Delay1_reg[0] <= 2'sb00;
        Delay1_reg[1] <= 2'sb00;
      end
      else begin
        if (enb) begin
          Delay1_reg[0] <= Delay1_reg_next[0];
          Delay1_reg[1] <= Delay1_reg_next[1];
        end
      end
    end

  assign Delay1_out1 = Delay1_reg[1];
  assign Delay1_reg_next[0] = Subsystem_out1;
  assign Delay1_reg_next[1] = Delay1_reg[0];



  assign out1 = Delay1_out1;

endmodule  // adpcm_encoder2

