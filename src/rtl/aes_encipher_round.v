//======================================================================
//
// aes_encipher_round.v
// --------------------
// The AES encipher round. A pure combinational module that implements
// the initial round, main round and final round logic for
// enciper operations.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2013, 2014, Secworks Sweden AB
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or 
// without modification, are permitted provided that the following 
// conditions are met: 
// 
// 1. Redistributions of source code must retain the above copyright 
//    notice, this list of conditions and the following disclaimer. 
// 
// 2. Redistributions in binary form must reproduce the above copyright 
//    notice, this list of conditions and the following disclaimer in 
//    the documentation and/or other materials provided with the 
//    distribution. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module aes_encipher_round(
                          input wire [127 : 0]  block,
                          input wire [127 : 0]  round_key,
                          input wire [1 : 0]    round_type,

                          input wire [7 : 0]    s00,
                          input wire [7 : 0]    s01,
                          input wire [7 : 0]    s02,
                          input wire [7 : 0]    s03,

                          input wire [7 : 0]    s10,
                          input wire [7 : 0]    s11,
                          input wire [7 : 0]    s12,
                          input wire [7 : 0]    s13,

                          input wire [7 : 0]    s20,
                          input wire [7 : 0]    s21,
                          input wire [7 : 0]    s22,
                          input wire [7 : 0]    s23,

                          input wire [7 : 0]    s30,
                          input wire [7 : 0]    s31,
                          input wire [7 : 0]    s32,
                          input wire [7 : 0]    s33,

                          output wire [7 : 0]   s00_new;
                          output wire [7 : 0]   s01_new;
                          output wire [7 : 0]   s02_new;
                          output wire [7 : 0]   s03_new;

                          output wire [7 : 0]   s10_new;
                          output wire [7 : 0]   s11_new;
                          output wire [7 : 0]   s12_new;
                          output wire [7 : 0]   s13_new;

                          output wire [7 : 0]   s20_new;
                          output wire [7 : 0]   s21_new;
                          output wire [7 : 0]   s22_new;
                          output wire [7 : 0]   s23_new;

                          output wire [7 : 0]   s30_new;
                          output wire [7 : 0]   s31_new;
                          output wire [7 : 0]   s32_new;
                          output wire [7 : 0]   s33_new;
                          
                          input wire [127 : 0]  block,
                          output wire [127 : 0] result,
                          output wire           result_valid
                         );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter INIT_ROUND  = 0;
  parameter MAIN_ROUND  = 1;
  parameter FINAL_ROUND = 2;

 
  //----------------------------------------------------------------
  // Gaolis multiplication functions for MixColumn and 
  // Inverse MixColumn.
  //----------------------------------------------------------------
  function [7 : 0] gmul2(input [7 : 0] op);
    begin
      gmul2 = {s00_0[6 : 0], 1'b0} ^ (8'h1b & {8{b[7]}});
    end
  endfunction // gmul2

  function [7 : 0] gmul3(input [7 : 0] op);
    begin
      gmul3 = gmul2(op) ^ op;
    end
  endfunction // gmul3
  
  
  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  
  
  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  wire [7 : 0] sbox00_data;
  wire [7 : 0] sbox01_data;
  wire [7 : 0] sbox02_data;
  wire [7 : 0] sbox03_data;
  wire [7 : 0] sbox10_data;
  wire [7 : 0] sbox11_data;
  wire [7 : 0] sbox12_data;
  wire [7 : 0] sbox13_data;
  wire [7 : 0] sbox20_data;
  wire [7 : 0] sbox21_data;
  wire [7 : 0] sbox22_data;
  wire [7 : 0] sbox23_data;
  wire [7 : 0] sbox30_data;
  wire [7 : 0] sbox31_data;
  wire [7 : 0] sbox32_data;
  wire [7 : 0] sbox33_data;

  
  //----------------------------------------------------------------
  // Instantiations.
  //----------------------------------------------------------------
  aes_sbox sbox00(.addr(sbox00_reg), .data(sbox00_data));
  aes_sbox sbox01(.addr(sbox01_reg), .data(sbox01_data));
  aes_sbox sbox02(.addr(sbox02_reg), .data(sbox02_data));
  aes_sbox sbox03(.addr(sbox03_reg), .data(sbox03_data));
  aes_sbox sbox10(.addr(sbox10_reg), .data(sbox10_data));
  aes_sbox sbox11(.addr(sbox11_reg), .data(sbox11_data));
  aes_sbox sbox12(.addr(sbox12_reg), .data(sbox12_data));
  aes_sbox sbox13(.addr(sbox13_reg), .data(sbox13_data));
  aes_sbox sbox20(.addr(sbox20_reg), .data(sbox20_data));
  aes_sbox sbox21(.addr(sbox21_reg), .data(sbox21_data));
  aes_sbox sbox22(.addr(sbox22_reg), .data(sbox22_data));
  aes_sbox sbox23(.addr(sbox23_reg), .data(sbox23_data));
  aes_sbox sbox30(.addr(sbox30_reg), .data(sbox30_data));
  aes_sbox sbox31(.addr(sbox31_reg), .data(sbox31_data));
  aes_sbox sbox32(.addr(sbox32_reg), .data(sbox32_data));
  aes_sbox sbox33(.addr(sbox33_reg), .data(sbox33_data));


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------


  //----------------------------------------------------------------
  // round_logic
  //
  // The logic needed to implement init, main and final rounds.
  //----------------------------------------------------------------
  always @*
    begin : round_logic
      // Wires for internal intermediate values.
      reg [7 : 0] s00_0, s00_1;
      reg [7 : 0] s01_0, s01_1;
      reg [7 : 0] s02_0, s02_1;
      reg [7 : 0] s03_0, s03_1;
      reg [7 : 0] s10_0, s10_1;
      reg [7 : 0] s11_0, s11_1;
      reg [7 : 0] s12_0, s12_1;
      reg [7 : 0] s13_0, s13_1;
      reg [7 : 0] s20_0, s20_1;
      reg [7 : 0] s21_0, s21_1;
      reg [7 : 0] s22_0, s22_1;
      reg [7 : 0] s23_0, s23_1;
      reg [7 : 0] s30_0, s30_1;
      reg [7 : 0] s31_0, s31_1;
      reg [7 : 0] s32_0, s32_1;
      reg [7 : 0] s33_0, s33_1;

      // Default assignments.
      s00_new = 8'h00;
      s01_new = 8'h00;
      s02_new = 8'h00;
      s03_new = 8'h00;
      s10_new = 8'h00;
      s11_new = 8'h00;
      s12_new = 8'h00;
      s13_new = 8'h00;
      s20_new = 8'h00;
      s21_new = 8'h00;
      s22_new = 8'h00;
      s23_new = 8'h00;
      s30_new = 8'h00;
      s31_new = 8'h00;
      s32_new = 8'h00;
      s33_new = 8'h00;
      s_we    = 0;
      
      if (init_state)
        begin
          // We tranfer the given block into state and do initial
          // AddRoundKey. This assumes that all keys start at
          // key[255] and extend downwards for 128, 192 or 256 bits.
          sa00_new = block[127 : 120] ^ round_key[255 : 248];
          sa10_new = block[119 : 112] ^ round_key[247 : 240];
          sa20_new = block[111 : 104] ^ round_key[239 : 232];
          sa30_new = block[103 : 096] ^ round_key[231 : 224];
          sa01_new = block[095 : 088] ^ round_key[223 : 216];
          sa11_new = block[087 : 080] ^ round_key[215 : 208];
          sa21_new = block[079 : 072] ^ round_key[207 : 200];
          sa31_new = block[071 : 064] ^ round_key[199 : 192];
          sa02_new = block[063 : 056] ^ round_key[191 : 184];
          sa12_new = block[055 : 048] ^ round_key[183 : 176];
          sa22_new = block[047 : 040] ^ round_key[175 : 168];
          sa32_new = block[039 : 032] ^ round_key[167 : 160];
          sa03_new = block[031 : 024] ^ round_key[159 : 152];
          sa13_new = block[023 : 016] ^ round_key[151 : 144];
          sa23_new = block[015 : 008] ^ round_key[143 : 136];
          sa33_new = block[007 : 000] ^ round_key[135 : 128];
          swe = 1;
        end
      else if (update_state)
        begin
          // SubBytes - Done through connectivity of sbox instances.
          // sbox_data wires contains the substitute values.
          
          // Shiftrows
          s00_0 = sbox00_data;
          s01_0 = sbox01_data;
          s02_0 = sbox02_data;
          s03_0 = sbox03_data;
          s10_0 = sbox11_data;
          s11_0 = sbox12_data;
          s12_0 = sbox13_data;
          s13_0 = sbox10_data;
          s20_0 = sbox22_data;
          s21_0 = sbox23_data;
          s22_0 = sbox20_data;
          s23_0 = sbox21_data;
          s30_0 = sbox33_data;
          s31_0 = sbox30_data;
          s32_0 = sbox31_data;
          s33_0 = sbox32_data;

          // MixColumns
          s00_1 = gm2(s00_0) ^ gm3(s10_0) ^ s20_0      ^ s30_0;
          s10_1 = s00_0      ^ gm2(s10_0) ^ gm3(s20_0) ^ s30_0;
          s20_1 = s00_0      ^ s10_0      ^ gm2(s20_0) ^ gm3(s30_0);
          s30_1 = gm3(s00_0) ^ s10_0      ^ s20_0      ^ gm2(s30_0);

          s01_1 = gm2(s01_0) ^ gm3(s11_0) ^ s21_0      ^ s31_0;
          s11_1 = s01_0      ^ gm2(s11_0) ^ gm3(s21_0) ^ s31_0;
          s21_1 = s01_0      ^ s11_0      ^ gm2(s21_0) ^ gm3(s31_0);
          s31_1 = gm3(s01_0) ^ s11_0      ^ s21_1      ^ gm2(s31_0);

          s02_1 = gm2(s02_0) ^ gm3(s12_0) ^ s22_0      ^ s32_0;
          s12_1 = s02_0      ^ gm2(s12_0) ^ gm3(s22_0) ^ s32_0;
          s22_1 = s02_0      ^ s12_0      ^ gm2(s22_0) ^ gm3(s32_0);
          s32_1 = gm3(s02_0) ^ s12_0      ^ s22_1      ^ gm2(s32_0);

          s03_1 = gm2(s03_0) ^ gm3(s13_0) ^ s23_0      ^ s33_0;
          s13_1 = s03_0      ^ gm2(s13_0) ^ gm3(s23_0) ^ s33_0;
          s23_1 = s03_0      ^ s13_0      ^ gm2(s23_0) ^ gm3(s33_0);
          s33_1 = gm3(s03_0) ^ s13_0      ^ s23_1      ^ gm2(s33_0);
          
          // AddRoundKey
          // TODO: Add correct round_key indices.
          s00_new = s00_1 ^ round_key[127 : 120];
          s01_new = s01_1 ^ round_key[119 : 112];
          s02_new = s02_1 ^ round_key[111 : 104];
          s03_new = s03_1 ^ round_key[103 :  96];
          s10_new = s10_1 ^ round_key[95  :  88];
          s11_new = s11_1 ^ round_key[87  :  80];
          s12_new = s12_1 ^ round_key[79  :  72];
          s13_new = s13_1 ^ round_key[71  :  64];
          s20_new = s20_1 ^ round_key[63  :  56];
          s21_new = s21_1 ^ round_key[55  :  48];
          s22_new = s22_1 ^ round_key[47  :  40];
          s23_new = s23_1 ^ round_key[39  :  32];
          s30_new = s30_1 ^ round_key[31  :  24];
          s31_new = s31_1 ^ round_key[23  :  16];
          s32_new = s32_1 ^ round_key[15  :   8];
          s33_new = s33_1 ^ round_key[7   :   0];
          swe = 1;
        end
    end // round_logic
endmodule // aes_encipher_round

//======================================================================
// EOF aes_encipher_round.v
//======================================================================