`timescale 1ns / 1ps

module WB_stage(
    input clk1,
    input TAKEN_BRANCH,
    input [2:0] MEM_WB_Type,
    input [31:0] MEM_WB_IR,
    input [31:0] MEM_WB_ALUout,
    input [31:0] MEM_WB_LMD,
    
    output reg [31:0] DATA_OUT,
    output reg HALTED,
    
    output reg RegWrite,
    output reg [4:0] WriteReg,
    output reg [31:0] WriteData
    );

parameter RR_ALU=3'b000, 
          RM_ALU=3'b001, 
          LOAD=3'b010, 
          HALT=3'b101;

initial begin
    DATA_OUT  = 0;
    HALTED    = 0;
    RegWrite  = 0;
    WriteReg  = 0;
    WriteData = 0;
end

initial HALTED = 0;
always @(posedge clk1)begin
        RegWrite <= 0;
            if(TAKEN_BRANCH == 0) // Disable write if branch taken
                RegWrite <= 0;
                
               case(MEM_WB_Type)
                    RR_ALU:begin
                         RegWrite  <= 1;
                         WriteReg  <= MEM_WB_IR[15:11];
                         WriteData <= MEM_WB_ALUout; //rd
                         DATA_OUT <= #2 MEM_WB_ALUout;
                    end
                    RM_ALU:begin
                         RegWrite  <= 1;
                         WriteReg  <= MEM_WB_IR[20:16];
                         WriteData <= MEM_WB_ALUout; //rt
                         DATA_OUT <= #2 MEM_WB_ALUout;
                    end
                    LOAD:begin
                           RegWrite  <= 1;
                           WriteReg  <= MEM_WB_IR[20:16];
                           WriteData <= MEM_WB_LMD; //rt
                           DATA_OUT <= #2 MEM_WB_LMD;
                    end
                    HALT: begin
                      HALTED <= #2 1'b1;
                      RegWrite <= 0;
                    end
               endcase 
         end  
endmodule