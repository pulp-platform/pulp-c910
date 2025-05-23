/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// &ModuleBeg; @22
module ct_spsram_512x59(
  A,
  CEN,
  CLK,
  D,
  GWEN,
  Q,
  WEN
);

// &Ports; @23
input   [8 :0]  A;   
input           CEN; 
input           CLK; 
input   [58:0]  D;   
input           GWEN; 
input   [58:0]  WEN; 
output  [58:0]  Q;   

// &Regs; @24

// &Wires; @25
wire    [8 :0]  A;   
wire            CEN; 
wire            CLK; 
wire    [58:0]  D;   
wire            GWEN; 
wire    [58:0]  Q;   
wire    [58:0]  WEN; 


//**********************************************************
//                  Parameter Definition
//**********************************************************
parameter ADDR_WIDTH = 9;
parameter DATA_WIDTH = 59;
parameter WE_WIDTH   = 59;

// &Force("bus","Q",DATA_WIDTH-1,0); @34
// &Force("bus","WEN",WE_WIDTH-1,0); @35
// &Force("bus","A",ADDR_WIDTH-1,0); @36
// &Force("bus","D",DATA_WIDTH-1,0); @37

  //********************************************************
  //*                        FPGA memory                   *
  //********************************************************
  //{WEN[58],WEN[57:29],WEN[28:0]}
//   &Instance("ct_f_spsram_512x59"); @44
tc_sram #(
  .NumWords   ( 1<<ADDR_WIDTH         ),
  .DataWidth  ( DATA_WIDTH            ),
  .ByteWidth  ( DATA_WIDTH/DATA_WIDTH ),
  .NumPorts   ( 32'd1 ),
  .Latency    ( 32'd1 ),
  .SimInit    ( "none"),
  .PrintSimCfg( 0     )
) i_tc_sram (
    .clk_i    ( CLK   ),
    .rst_ni   ( 1'b1  ),
    .req_i    ( ~CEN  ),
    .we_i     ( ~GWEN ),
    .be_i     ( ~WEN  ),
    .wdata_i  ( D     ),
    .addr_i   ( A     ),
    .rdata_o  ( Q     )
);

//   &Instance("ct_tsmc_spsram_512x59"); @50

// &ModuleEnd; @66
endmodule


