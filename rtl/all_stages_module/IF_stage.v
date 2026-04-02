`timescale 1ns / 1ps

module IF_stage(
    input clk1,
    input HALTED,
    input [31:0] EX_MEM_IR,
    input        EX_MEM_Cond,
    input [31:0] EX_MEM_ALUout,
    input [31:0] Instruction1,         //memory
    //input [31:0] Instruction2,
    output reg [31:0] IF_ID_IR,
    output reg [31:0] IF_ID_NPC,
    output reg [31:0] PC
);

//reg [31:0] mem [0:1023];
parameter BEQZ  = 6'b001110;
parameter BNEQZ = 6'b001101;

initial begin
    IF_ID_IR  = 0;
    IF_ID_NPC = 0;
    PC        = 0;
end
    
always @(posedge clk1)
if(HALTED == 0) begin
    if(((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_Cond == 1)) || 
       ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_Cond == 0))) 
    begin
        IF_ID_IR <= #2 32'b0; //Instruction2;
        //TAKEN_BRANCH <= #2 1'b1;
        
        IF_ID_NPC <= #2 EX_MEM_ALUout + 1;
        PC <= #2 EX_MEM_ALUout + 1;
    end
    else
    begin
        IF_ID_IR <= #2 Instruction1;
        IF_ID_NPC <= #2 PC + 1;
        PC <= #2 PC + 1;
    end
end

endmodule