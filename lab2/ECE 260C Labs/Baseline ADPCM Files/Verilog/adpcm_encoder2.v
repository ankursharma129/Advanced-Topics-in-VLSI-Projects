// -------------------------------------------------------------
// 
// File Name: Piplined_encoder\adpcm_precision_study\adpcm_encoder2.v
// Created: 2022-04-30 14:10:34
// 
// Generated by MATLAB 9.11 and HDL Coder 3.19
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: adpcm_encoder2
// Source Path: adpcm_precision_study/ADPCM_ECD/adpcm encoder2
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
  input   signed [19:0] in1;  // sfix20_En16
  output  signed [1:0] out1;  // sfix2


  reg signed [19:0] Delay2_out1;  // sfix20_En16
  reg signed [19:0] PL3_out1;  // sfix20_En16
  wire signed [27:0] IntegratorGain_out1;  // sfix28_En24
  wire signed [19:0] Subsystem_out2;  // sfix20_En16
  reg signed [19:0] PL1_out1;  // sfix20_En16
  wire signed [19:0] ADPCM_Decoder_out1;  // sfix20_En16
  wire signed [31:0] Sum_sub_cast;  // sfix32_En16
  wire signed [31:0] Sum_sub_cast_1;  // sfix32_En16
  wire signed [31:0] Sum_sub_temp;  // sfix32_En16
  wire signed [19:0] Sum_out1;  // sfix20_En16
  wire signed [1:0] Subsystem_out1;  // sfix2
  reg signed [1:0] PL2_out1;  // sfix2
  reg signed [1:0] Delay1_out1;  // sfix2

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
        Delay2_out1 <= 20'sb00000000000000000000;
      end
      else begin
        if (enb) begin
          Delay2_out1 <= in1;
        end
      end
    end



  always @(posedge clk or posedge reset)
    begin : PL3_process
      if (reset == 1'b1) begin
        PL3_out1 <= 20'sb00000000000000000000;
      end
      else begin
        if (enb) begin
          PL3_out1 <= Delay2_out1;
        end
      end
    end



  assign IntegratorGain_out1 = 28'sb0000111111011111001110110110;



  always @(posedge clk or posedge reset)
    begin : PL1_process
      if (reset == 1'b1) begin
        PL1_out1 <= 20'sb00000000000000000000;
      end
      else begin
        if (enb) begin
          PL1_out1 <= Subsystem_out2;
        end
      end
    end



  ADPCM_Decoder u_ADPCM_Decoder (.clk(clk),
                                 .reset(reset),
                                 .enb(enb),
                                 .In1(PL1_out1),  // sfix20_En16
                                 .LoopGain(IntegratorGain_out1),  // sfix28_En24
                                 .Out1(ADPCM_Decoder_out1)  // sfix20_En16
                                 );

  assign Sum_sub_cast = {{12{PL3_out1[19]}}, PL3_out1};
  assign Sum_sub_cast_1 = {{12{ADPCM_Decoder_out1[19]}}, ADPCM_Decoder_out1};
  assign Sum_sub_temp = Sum_sub_cast - Sum_sub_cast_1;
  assign Sum_out1 = ((Sum_sub_temp[31] == 1'b0) && (Sum_sub_temp[30:19] != 12'b000000000000) ? 20'sb01111111111111111111 :
              ((Sum_sub_temp[31] == 1'b1) && (Sum_sub_temp[30:19] != 12'b111111111111) ? 20'sb10000000000000000000 :
              $signed(Sum_sub_temp[19:0])));



  Subsystem_block1 u_Subsystem (.In1(Sum_out1),  // sfix20_En16
                                .Out1(Subsystem_out1),  // sfix2
                                .Out2(Subsystem_out2)  // sfix20_En16
                                );

  always @(posedge clk or posedge reset)
    begin : PL2_process
      if (reset == 1'b1) begin
        PL2_out1 <= 2'sb00;
      end
      else begin
        if (enb) begin
          PL2_out1 <= Subsystem_out1;
        end
      end
    end



  always @(posedge clk or posedge reset)
    begin : Delay1_process
      if (reset == 1'b1) begin
        Delay1_out1 <= 2'sb00;
      end
      else begin
        if (enb) begin
          Delay1_out1 <= PL2_out1;
        end
      end
    end



  assign out1 = Delay1_out1;

endmodule  // adpcm_encoder2
