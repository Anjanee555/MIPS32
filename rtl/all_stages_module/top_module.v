`timescale 1ns / 1ps

module mips32_top(
    input clk1,
    input clk2,
    output [31:0] DATA_OUT
);

//Pipeline Wires 

wire [31:0] IF_ID_IR, IF_ID_NPC, PC;
wire [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
wire [2:0]  ID_EX_Type,EX_MEM_Type,MEM_WB_Type;
wire [31:0] EX_MEM_IR, EX_MEM_ALUout, EX_MEM_B;
wire        EX_MEM_Cond;
wire [31:0] MEM_WB_IR, MEM_WB_ALUout, MEM_WB_LMD;
wire        TAKEN_BRANCH;
wire        HALTED; 
reg [31:0]  Reg [0:31];
reg [31:0]  MEM_OUT [0:1023];

//IF STAGE 
wire [31:0] Instruction1;//Instruction2;
assign Instruction1 = MEM_OUT[PC];
//assign Instruction2 = MEM_OUT[EX_MEM_ALUout];

IF_stage IF1(
    .clk1(clk1),
    .HALTED(HALTED),
    .EX_MEM_IR(EX_MEM_IR),
    .EX_MEM_Cond(EX_MEM_Cond),
    .EX_MEM_ALUout(EX_MEM_ALUout),
    .Instruction1(Instruction1),
    //.Instruction2(Instruction2),
    .IF_ID_IR(IF_ID_IR),
    .IF_ID_NPC(IF_ID_NPC),
    .PC(PC)
);

//ID STAGE 
wire [31:0] RegData1, RegData2;
assign RegData1 = (IF_ID_IR[25:21] == 0) ? 0 : Reg[IF_ID_IR[25:21]];
assign RegData2 = (IF_ID_IR[20:16] == 0) ? 0 : Reg[IF_ID_IR[20:16]];

ID_stage ID1(
    .clk2(clk2),
    .HALTED(HALTED),
    .IF_ID_IR(IF_ID_IR),
    .IF_ID_NPC(IF_ID_NPC),
    .RegData1(RegData1),
    .RegData2(RegData2),
    .ID_EX_IR(ID_EX_IR),
    .ID_EX_NPC(ID_EX_NPC),
    .ID_EX_A(ID_EX_A),
    .ID_EX_B(ID_EX_B),
    .ID_EX_Imm(ID_EX_Imm),
    .ID_EX_Type(ID_EX_Type)
);

// EX STAGE 

EX_stage EX1(
    .clk1(clk1),
    .HALTED(HALTED),
    .ID_EX_IR(ID_EX_IR),
    .ID_EX_A(ID_EX_A),
    .ID_EX_B(ID_EX_B),
    .ID_EX_Imm(ID_EX_Imm),
    .ID_EX_NPC(ID_EX_NPC),
    .ID_EX_Type(ID_EX_Type),
    .EX_MEM_IR(EX_MEM_IR),
    .EX_MEM_ALUout(EX_MEM_ALUout),
    .EX_MEM_B(EX_MEM_B),
    .EX_MEM_Cond(EX_MEM_Cond),
    .EX_MEM_Type(EX_MEM_Type),
    .TAKEN_BRANCH(TAKEN_BRANCH)
);

//MEM STAGE
wire [31:0] MemReadData;
wire [31:0] MemWriteData;
wire [31:0] MemAddress;
wire MemWrite;
assign MemReadData = MEM_OUT[EX_MEM_ALUout];//read
// Write
always @(posedge clk2) begin
    if (MemWrite)
        MEM_OUT[MemAddress] <= MemWriteData;
end

MEM_stage MEM1(
    .clk2(clk2),
    .HALTED(HALTED),
    .TAKEN_BRANCH(TAKEN_BRANCH),
    .EX_MEM_Type(EX_MEM_Type),
    .EX_MEM_IR(EX_MEM_IR),
    .EX_MEM_ALUout(EX_MEM_ALUout),
    .EX_MEM_B(EX_MEM_B),
    .MEM_WB_IR(MEM_WB_IR),
    .MEM_WB_ALUout(MEM_WB_ALUout),
    .MEM_WB_LMD(MEM_WB_LMD),
    .MEM_WB_Type(MEM_WB_Type),
    .MemReadData(MemReadData),
    .MemWriteData(MemWriteData),
    .MemAddress(MemAddress),
    .MemWrite(MemWrite)
);

//WB STAGE 
wire WB_RegWrite;
wire [4:0] WB_WriteReg;
wire [31:0] WB_WriteData;

WB_stage WB1(
    .clk1(clk1),
    .TAKEN_BRANCH(TAKEN_BRANCH),
    .MEM_WB_Type(MEM_WB_Type),
    .MEM_WB_IR(MEM_WB_IR),
    .MEM_WB_ALUout(MEM_WB_ALUout),
    .MEM_WB_LMD(MEM_WB_LMD),
    .RegWrite(WB_RegWrite),     
    .WriteReg(WB_WriteReg),    
    .WriteData(WB_WriteData),
    .HALTED(HALTED),
    .DATA_OUT(DATA_OUT)
);

always @(posedge clk1) begin
    if (WB_RegWrite)
        Reg[WB_WriteReg] <= WB_WriteData;
end

endmodule