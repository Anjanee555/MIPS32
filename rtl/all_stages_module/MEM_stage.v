`timescale 1ns / 1ps

module MEM_stage(
    input clk2,
    input HALTED,
    input TAKEN_BRANCH,
    input [2:0] EX_MEM_Type,
    input [31:0] EX_MEM_IR,
    input [31:0] EX_MEM_ALUout,
    input [31:0] EX_MEM_B,
    output reg [31:0] MEM_WB_IR,
    output reg [31:0] MEM_WB_ALUout,
    output reg [31:0] MEM_WB_LMD,
    output reg [2:0] MEM_WB_Type,
    
    input [31:0] MemReadData,
    output reg [31:0] MemWriteData,
    output reg [31:0] MemAddress,
    output reg MemWrite         //memory
    
);
//reg [31:0] mem [0:1023];

parameter RR_ALU=3'b000, 
          RM_ALU=3'b001, 
          LOAD=3'b010, 
          STORE=3'b011;

initial begin
    MEM_WB_IR     = 0;
    MEM_WB_ALUout = 0;
    MEM_WB_LMD    = 0;
    MEM_WB_Type   = 0;
    MemWrite      = 0;
    MemAddress    = 0;
    MemWriteData  = 0;
end

always @(posedge clk2)
    if(HALTED == 0)begin
            MEM_WB_IR <= #2 EX_MEM_IR;
            MEM_WB_Type <= #2 EX_MEM_Type;
            MemWrite <= 0;

            case(EX_MEM_Type)
                RR_ALU,RM_ALU: MEM_WB_ALUout <= EX_MEM_ALUout;
                LOAD: MEM_WB_LMD <= #2 MemReadData;
                STORE: begin
                    MemAddress <= EX_MEM_ALUout;
                    MemWriteData <= EX_MEM_B;
                    MemWrite <= 1;
                end
        endcase
    
    end

endmodule