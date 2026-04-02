`timescale 1ns / 1ps

module ID_stage(
    input clk2,
    input HALTED,
    input [31:0]      IF_ID_IR,
    input [31:0]      IF_ID_NPC,
    input [31:0] RegData1,
    input [31:0] RegData2 ,
    output reg [31:0] ID_EX_IR,
    output reg [31:0] ID_EX_NPC,
    output reg [31:0] ID_EX_A,
    output reg [31:0] ID_EX_B,
    output reg [31:0] ID_EX_Imm,
    output reg [2:0] ID_EX_Type
);
parameter ADD   = 6'b000000,
          SUB   = 6'b000001,
          AND   = 6'b000010,
          OR    = 6'b000011,
          SLT   = 6'b000100,
          MUL   = 6'b000101,
          LW    = 6'b001000,
          SW    = 6'b001001,
          ADDI  = 6'b001010,
          SUBI  = 6'b001011,
          SLTI  = 6'b001100,
          BNEQZ = 6'b001101,
          BEQZ  = 6'b001110,
          HLT   = 6'b111111;

parameter RR_ALU = 3'b000,
          RM_ALU = 3'b001,
          LOAD   = 3'b010,
          STORE  = 3'b011,
          BRANCH = 3'b100,
          HALT   = 3'b101;
          
 initial begin
    ID_EX_IR   = 0;
    ID_EX_NPC  = 0;
    ID_EX_A    = 0;
    ID_EX_B    = 0;
    ID_EX_Imm  = 0;
    ID_EX_Type = 0;
end         
          
always @(posedge clk2)
if(HALTED == 0) begin
    if(IF_ID_IR == 32'b0) begin
        ID_EX_IR   <= 0;
        ID_EX_Type <= 0;
    end
    
    else begin
    if(IF_ID_IR[25:21] == 5'b00000) ID_EX_A <= 0;
    else ID_EX_A <= RegData1; //rs
            
    if(IF_ID_IR[20:16] == 5'b00000) ID_EX_B <= 0;
    else ID_EX_B <= RegData2; //rt

    ID_EX_IR <= #2 IF_ID_IR;
    ID_EX_NPC <= #2 IF_ID_NPC;
    ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}},IF_ID_IR[15:0]};

    case(IF_ID_IR[31:26])
        ADD,SUB,AND,OR,SLT,MUL: ID_EX_Type <= #2 RR_ALU;
        ADDI,SUBI,SLTI: ID_EX_Type <= #2 RM_ALU;
        LW: ID_EX_Type <= #2 LOAD;
        SW: ID_EX_Type <= #2 STORE;
        BEQZ,BNEQZ: ID_EX_Type <= #2 BRANCH;
        HLT: ID_EX_Type <= #2 HALT;
        default: ID_EX_Type <= #2 HALT;
    endcase
end
end

endmodule