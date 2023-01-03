// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Thu Jul 11 11:26:45 2013
// ============================================================================
module Vetris(

///////// ADC /////////
inout ADC_CS_N,
output ADC_DIN,
input ADC_DOUT,
output ADC_SCLK,

///////// AUD /////////
input AUD_ADCDAT,
inout AUD_ADCLRCK,
inout AUD_BCLK,
output AUD_DACDAT,
inout AUD_DACLRCK,
output AUD_XCK,

///////// CLOCKS /////////
input CLOCK2_50,
input CLOCK3_50,
input CLOCK4_50,
input CLOCK_50,

///////// DRAM /////////
output [12:0] DRAM_ADDR,
output [1:0] DRAM_BA,
output DRAM_CAS_N,
output DRAM_CKE,
output DRAM_CLK,
output DRAM_CS_N,
inout [15:0] DRAM_DQ,
output DRAM_LDQM,
output DRAM_RAS_N,
output DRAM_UDQM,
output DRAM_WE_N,

///////// FAN /////////
output FAN_CTRL,

///////// FPGA /////////
output FPGA_I2C_SCLK,
inout FPGA_I2C_SDAT,

///////// GPIO /////////
inout [35:0] GPIO_0,
 
///////// HEX0 /////////
output [6:0] HEX0,
output [6:0] HEX1,
output [6:0] HEX2,
output [6:0] HEX3,
output [6:0] HEX4,
output [6:0] HEX5,
input IRDA_RXD,
output IRDA_TXD,
///////// KEY /////////
input [3:0] KEY,
///////// LEDR /////////
output [9:0] LEDR,
///////// PS2 /////////
inout PS2_CLK,
inout PS2_CLK2,
inout PS2_DAT,
inout PS2_DAT2,
///////// SW /////////
input [9:0] SW,
///////// TD /////////
input TD_CLK27,
input [7:0] TD_DATA,
input TD_HS,
output TD_RESET_N,
input TD_VS,

///////// VGA /////////
output [7:0] VGA_B,
output VGA_BLANK_N,
output VGA_CLK,
output [7:0] VGA_G,
output VGA_HS,
output [7:0] VGA_R,
output VGA_SYNC_N,
output VGA_VS,
  
//////////// GPIO1, GPIO1 connect to D5M - 5M Pixel Camera //////////
input [11:0] D5M_D,
input D5M_FVAL,
input D5M_LVAL,
input D5M_PIXLCLK,
output D5M_RESET_N,
output D5M_SCLK,
inout D5M_SDATA,
input D5M_STROBE,
output D5M_TRIGGER,
output D5M_XCLKIN
);

//  Signal declarations
logic [15:0] Read_DATA1;
logic [15:0] Read_DATA2;
logic [11:0] mCCD_DATA;
logic mCCD_DVAL;
logic mCCD_DVAL_d;
logic [15:0] X_Cont;
logic [15:0] Y_Cont;
logic [9:0] X_ADDR;
logic [31:0] Frame_Cont;
logic DLY_RST_0;
logic DLY_RST_1;
logic DLY_RST_2;
logic DLY_RST_3;
logic DLY_RST_4;
logic Read;
logic [11:0] rCCD_DATA;
logic rCCD_LVAL;
logic rCCD_FVAL;
logic [11:0] sCCD_R;
logic [11:0] sCCD_G;
logic [11:0] sCCD_B;
logic sCCD_DVAL;
logic sdram_ctrl_clk;
logic [9:0] oVGA_R;
logic [9:0] oVGA_G;
logic [9:0] oVGA_B;
logic auto_start;

wire [11:0] graphicsDataRed;
wire [11:0] graphicsDataGreen;
wire [11:0] graphicsDataBlue;
assign sCCD_R = graphicsDataRed;
assign sCCD_G = graphicsDataGreen;
assign sCCD_B = graphicsDataBlue;

// Connections
// D5M
assign D5M_TRIGGER = 1'b1;
assign D5M_RESET_N = DLY_RST_1;
assign VGA_CTRL_CLK = VGA_CLK;
assign LEDR = Y_Cont;

//fetch the high 8 bits
assign VGA_R = oVGA_R[9:2];
assign VGA_G = oVGA_G[9:2];
assign VGA_B = oVGA_B[9:2];

//D5M read 
always@(posedge D5M_PIXLCLK)
begin
 rCCD_DATA <= D5M_D;
 rCCD_LVAL <= D5M_LVAL;
 rCCD_FVAL <= D5M_FVAL;
end

// Start when power on
assign auto_start = KEY[0] && DLY_RST_3 && !DLY_RST_4 ? 1'b1 : 1'b0;

// CPU signal declarations
logic [31:0] in_reg_data, idata, input_reg_update;
logic final_isMoveOrWriteShape;
logic [4:0] index;

logic [31:0] PC_out_test;
// CPU
CPU iCPU (
    // Inputs
    .clk(D5M_PIXLCLK),
    .rst(DLY_RST_2),
    .in_reg_data(in_reg_data),
    // Outputs
    .final_isMoveOrWriteShape(final_isMoveOrWriteShape),
    .row_data(idata),
    .input_reg_update(input_reg_update),
    .index_data_out(index),
    .PC_out_test(PC_out_test)
);

// Input Module
Input iInput (
    // Inputs
    .clk(D5M_PIXLCLK),
    .rst(DLY_RST_2),
    .KEY(KEY),
    .sprIn(input_reg_update),
    .updateInpReg(final_isMoveOrWriteShape),
    // Outputs
    .GPIO(GPIO_0),
    .sprOut(in_reg_data),
    .timerVal(timerVal),
 .moveChange(SW[9:8])
);
logic [31:0] timerVal;

//Reset module
Reset_Delay resets( 
    .iCLK(CLOCK_50),
    .iRST(KEY[0]),
    .oRST_0(DLY_RST_0),
    .oRST_1(DLY_RST_1),
    .oRST_2(DLY_RST_2),
    .oRST_3(DLY_RST_3),
    .oRST_4(DLY_RST_4)
);

//D5M image capture
CCD_Capture ccd_capture( 
    .oDATA(mCCD_DATA),
    .oDVAL(mCCD_DVAL),
    .oX_Cont(X_Cont),
    .oY_Cont(Y_Cont),
    .oFrame_Cont(Frame_Cont),
    .iDATA(rCCD_DATA),
    .iFVAL(rCCD_FVAL),
    .iLVAL(rCCD_LVAL),
    .iSTART(!KEY[3]|auto_start),
    // .iEND(!KEY[2]),
    .iCLK(~D5M_PIXLCLK),
    .iRST(DLY_RST_2)
);

RAW2RGB iRaw2RGB(	
    .iCLK(D5M_PIXLCLK),
    .iRST(DLY_RST_1),
    .iDATA(mCCD_DATA),
    .iDVAL(mCCD_DVAL),
    .oRed(),
    .oGreen(),
    .oBlue(),
    .oDVAL(sCCD_DVAL),
    .iX_Cont(X_Cont),
    .iY_Cont(Y_Cont)
);

Graphics iGraphics(
   .clk(D5M_PIXLCLK),
   .rst(DLY_RST_1),
   .index(index),
   .iData(idata),
   .oDataRed(graphicsDataRed),
   .oDataGreen(graphicsDataGreen),
   .oDataBlue(graphicsDataBlue),
   .dVal(sCCD_DVAL)
);

logic [23:0] sevSegOut;
logic [23:0] sevSegInputReg;
assign sevSegInputReg[3:0] = {1'b0, in_reg_data[2:0]};
assign sevSegInputReg[7:4] = in_reg_data[6:3];
assign sevSegInputReg[15:8] = {2'b0, in_reg_data[12:7]};
assign sevSegInputReg[23:16] = {6'b0, in_reg_data[14:13]};
assign sevSegOut = SW[2] ? PC_out_test : (SW[1] ? sevSegInputReg : (SW[0] ? {16'b0,timerVal[31:24]} : timerVal[23:0]));
//Frame count display
SEG7_LUT_6 seven_seg_lut( 
    .oSEG0(HEX0),
    .oSEG1(HEX1),
    .oSEG2(HEX2),
    .oSEG3(HEX3),
    .oSEG4(HEX4),
    .oSEG5(HEX5),
    .iDIG(sevSegOut)
);
        
sdram_pll sdram_clocks(
    .refclk(CLOCK_50),
    .rst(1'b0),
    .outclk_0(sdram_ctrl_clk),
    .outclk_1(DRAM_CLK),
    .outclk_2(D5M_XCLKIN),    //25M
    .outclk_3(VGA_CLK)       //25M
);

//SDRam Read and Write as Frame Buffer
Sdram_Control sdram_control(
    // HOST Side      
    .RESET_N(KEY[0]),
    .CLK(sdram_ctrl_clk),

    // FIFO Write Side 1
    .WR1_DATA({1'b0,sCCD_G[11:7],sCCD_B[11:2]}),
    .WR1(sCCD_DVAL),
    .WR1_ADDR(0),
    .WR1_MAX_ADDR(640*480),
    .WR1_LENGTH(8'h50),
    .WR1_LOAD(!DLY_RST_0),
    .WR1_CLK(~D5M_PIXLCLK),

    // FIFO Write Side 2
    .WR2_DATA({1'b0,sCCD_G[6:2],sCCD_R[11:2]}),
    .WR2(sCCD_DVAL),
    .WR2_ADDR(23'h100000),
    .WR2_MAX_ADDR(23'h100000+640*480),
    .WR2_LENGTH(8'h50),
    .WR2_LOAD(!DLY_RST_0),    
    .WR2_CLK(~D5M_PIXLCLK),

    // FIFO Read Side 1
    .RD1_DATA(Read_DATA1),
    .RD1(Read),
    .RD1_ADDR(0),
    .RD1_MAX_ADDR(640*480),
    .RD1_LENGTH(8'h50),
    .RD1_LOAD(!DLY_RST_0),
    .RD1_CLK(~VGA_CTRL_CLK),

    // FIFO Read Side 2
    .RD2_DATA(Read_DATA2),
    .RD2(Read),
    .RD2_ADDR(23'h100000),
    .RD2_MAX_ADDR(23'h100000+640*480),
    .RD2_LENGTH(8'h50),
    .RD2_LOAD(!DLY_RST_0),
    .RD2_CLK(~VGA_CTRL_CLK),

    // SDRAM Side
    .SA(DRAM_ADDR),
    .BA(DRAM_BA),
    .CS_N(DRAM_CS_N),
    .CKE(DRAM_CKE),
    .RAS_N(DRAM_RAS_N),
    .CAS_N(DRAM_CAS_N),
    .WE_N(DRAM_WE_N),
    .DQ(DRAM_DQ),
    .DQM({DRAM_UDQM,DRAM_LDQM})
);

//D5M I2C control
I2C_CCD_Config  u8(
    // Host Side
    .iCLK(CLOCK2_50),
    .iRST_N(DLY_RST_2),
    .iEXPOSURE_ADJ(1'b0),
    .iEXPOSURE_DEC_p(SW[0]),
    .iZOOM_MODE_SW(SW[9]),
    // I2C Side
    .I2C_SCLK(D5M_SCLK),
    .I2C_SDAT(D5M_SDATA)
);

//VGA DISPLAY
VGA_Controller u1(
    // Host Side
    .oRequest(Read),
    .iRed(Read_DATA2[9:0]),
    .iGreen({Read_DATA1[14:10], Read_DATA2[14:10]}),
    .iBlue(Read_DATA1[9:0]),
    // VGA Side
    .oVGA_R(oVGA_R),
    .oVGA_G(oVGA_G),
    .oVGA_B(oVGA_B),
    .oVGA_H_SYNC(VGA_HS),
    .oVGA_V_SYNC(VGA_VS),
    .oVGA_SYNC(VGA_SYNC_N),
    .oVGA_BLANK(VGA_BLANK_N),
    // Control Signal
    .iCLK(VGA_CTRL_CLK),
    .iRST_N(DLY_RST_2),
    .iZOOM_MODE_SW(SW[9])
);

endmodule
