`timescale 1ns / 1ps

module EX_stage(
    input clk1,
    input HALTED,
    input [31:0] ID_EX_IR,
    input [31:0] ID_EX_A,
    input [31:0] ID_EX_B,
    input [31:0] ID_EX_Imm,
    input [31:0] ID_EX_NPC,
    input [2:0] ID_EX_Type,
    output reg [31:0] EX_MEM_IR,
    output reg [31:0] EX_MEM_ALUout,
    output reg [31:0] EX_MEM_B,
    output reg EX_MEM_Cond,
    output reg [2:0] EX_MEM_Type,
    output reg TAKEN_BRANCH

);

parameter ADD=6'b000000, 
          SUB=6'b000001, 
          AND=6'b000010, 
          OR=6'b000011,
          SLT=6'b000100, 
          MUL=6'b000101,
          ADDI=6'b001010, 
          SUBI=6'b001011, 
          SLTI=6'b001100;

parameter RR_ALU=3'b000, 
          RM_ALU=3'b001, 
          LOAD=3'b010, 
          STORE=3'b011, 
          BRANCH=3'b100;

initial begin
    EX_MEM_IR     = 0;
    EX_MEM_ALUout = 0;
    EX_MEM_B      = 0;
    EX_MEM_Cond   = 0;
    EX_MEM_Type   = 0;
    TAKEN_BRANCH  = 0;
end

always @(posedge clk1)
if(HALTED == 0) begin

    EX_MEM_IR <= #2 ID_EX_IR;
    EX_MEM_Type <= #2 ID_EX_Type;
    TAKEN_BRANCH <= #2 0;

    case(ID_EX_Type)

        RR_ALU:begin
            case(ID_EX_IR[31:26])
                ADD: EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_B;
                SUB: EX_MEM_ALUout <= #2 ID_EX_A - ID_EX_B;
                AND: EX_MEM_ALUout <= #2 ID_EX_A & ID_EX_B;
                OR : EX_MEM_ALUout <= #2 ID_EX_A | ID_EX_B;
                SLT: EX_MEM_ALUout <= #2 ID_EX_A < ID_EX_B;
                MUL: EX_MEM_ALUout <= #2 ID_EX_A * ID_EX_B;
                default: EX_MEM_ALUout <= #2 32'bxxxxxxxx;
            endcase
        end

        RM_ALU:begin
            case(ID_EX_IR[31:26])
                ADDI: EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_Imm;
                SUBI: EX_MEM_ALUout <= #2 ID_EX_A - ID_EX_Imm;
                SLTI: EX_MEM_ALUout <= #2 ID_EX_A < ID_EX_Imm;
                default: EX_MEM_ALUout <= #2 32'bxxxxxxxx;
            endcase
        end

        LOAD,STORE:
            begin
                EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_Imm;
                EX_MEM_B <= #2 ID_EX_B;
            end

        BRANCH:
            begin
                EX_MEM_ALUout <= #2 ID_EX_NPC + ID_EX_Imm;
                EX_MEM_Cond <= #2 (ID_EX_A == 0);
                
                if ((ID_EX_IR[31:26] == 6'b001110 && (ID_EX_A == 0)) ||   // BEQZ
                    (ID_EX_IR[31:26] == 6'b001101 && (ID_EX_A != 0)))     // BNEQZ
                    TAKEN_BRANCH <= #2 1;
                else 
                    TAKEN_BRANCH <= #2 0;

            end

    endcase
end

endmodule