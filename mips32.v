`timescale 1ns / 1ps

module mips32( input clk1,clk2);
    reg [31:0] IF_ID_IR,IF_ID_NPC, PC;
    reg [31:0] ID_EX_IR,ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
	reg [2:0]  ID_EX_Type, EX_MEM_Type, MEM_WB_Type;
	reg        EX_MEM_Cond;
	reg [31:0] EX_MEM_B;
	reg [31:0] EX_MEM_ALUout;
    reg [31:0] EX_MEM_IR, MEM_WB_IR, MEM_WB_ALUout, MEM_WB_LMD;
    
    reg [31:0] regi [0:31]; //Register Bank (32x32)
    reg [31:0] mem [0:1023]; //Memory Bank (32x1024)
    
    parameter ADD = 6'b000000,
              SUB = 6'b000001,
              AND = 6'b000010,
              OR = 6'b000011,
              SLT = 6'b000100,
              MUL = 6'b000101,
              LW = 6'b001000,
              SW = 6'b001001,
              ADDI = 6'b001010,
              SUBI = 6'b001011,
              SLTI = 6'b001100,
              BNEQZ = 6'b001101,
              BEQZ = 6'b001110,
              HLT = 6'b111111;
              
     parameter RR_ALU = 3'b000,
               RM_ALU = 3'b001,
               LOAD = 3'b010,
               STORE = 3'b011,
               BRANCH = 3'b100,
               HALT = 3'b101;
               
     reg HALTED; // set after HLT instruction is completed in WB stage.
     reg TAKEN_BRANCH; // Required to disable instruction after branch.
     
     //IF STAGE----------------------------------------------------------------------------------------
  always  @(posedge clk1)
        if(HALTED == 0) begin
          if(((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_Cond == 1)) || 
             ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_Cond == 0))) 
                begin
                    IF_ID_IR <= #2 mem[EX_MEM_ALUout];
                    TAKEN_BRANCH <= #2 1'b1;                
                    IF_ID_NPC <= #2 EX_MEM_ALUout + 1;
                    PC <= EX_MEM_ALUout + 1;
                 end 
             else 
                begin 
                    IF_ID_IR <= #2 mem[PC];                
                    IF_ID_NPC <= #2 PC + 1;
                    PC <= #2 PC + 1;
                end            
        end
        
      //ID STAGE----------------------------------------------------------------------------------------
      always @(posedge clk2)
        if(HALTED == 0) begin
            if(IF_ID_IR[25:21] == 5'b00000) ID_EX_A <= 0;
            else ID_EX_A <= regi[IF_ID_IR [25:21]]; //rs
            
            if(IF_ID_IR[20:16] == 5'b00000) ID_EX_B <= 0;
            else ID_EX_B <= regi[IF_ID_IR [20:16]]; //rt
                
            ID_EX_NPC <= #2 IF_ID_NPC;
            ID_EX_IR <= #2 IF_ID_IR;
            ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]};
            
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
      
      //EX STAGE----------------------------------------------------------------------------------------
       always  @(posedge clk1)
        if(HALTED == 0) begin
            EX_MEM_Type <= #2 ID_EX_Type;
            EX_MEM_IR <= #2 ID_EX_IR;
            TAKEN_BRANCH <= #2 0;
            
            case(ID_EX_Type)
                RR_ALU: begin
                    case(ID_EX_IR[31:26]) //"OPCODE"
                      ADD : EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_B;
                      SUB : EX_MEM_ALUout <= #2 ID_EX_A - ID_EX_B;
                      AND : EX_MEM_ALUout <= #2 ID_EX_A & ID_EX_B;
                      OR  : EX_MEM_ALUout <= #2 ID_EX_A | ID_EX_B;
                      SLT : EX_MEM_ALUout <= #2 ID_EX_A < ID_EX_B;
                      MUL : EX_MEM_ALUout <= #2 ID_EX_A * ID_EX_B;
                      default: EX_MEM_ALUout <= #2 32'bxxxxxxxx;
                    endcase
                end
                   
                RM_ALU: begin
                    case(ID_EX_IR[31:26]) //"OPCODE"
                      ADDI : EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_Imm;
                      SUBI : EX_MEM_ALUout <= #2 ID_EX_A - ID_EX_Imm;
                      SLTI : EX_MEM_ALUout <= #2 (ID_EX_A < ID_EX_Imm);
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
                    end         
            endcase    
        end 
        
     //MEM STAGE----------------------------------------------------------------------------------------
     always @(posedge clk2)
       if(HALTED == 0) 
            begin
               MEM_WB_Type <= EX_MEM_Type; 
               MEM_WB_IR <= #2 EX_MEM_IR;
               
               case(EX_MEM_Type)
                    RR_ALU,RM_ALU: MEM_WB_ALUout <= EX_MEM_ALUout;
                    LOAD: MEM_WB_LMD <= #2 mem[EX_MEM_ALUout];
                    STORE: if(TAKEN_BRANCH == 0)   //Disable write
                                mem[EX_MEM_ALUout] <= #2 EX_MEM_B;
               endcase 
      end                 
      
     //WB STAGE----------------------------------------------------------------------------------------
     always @(posedge clk1) 
        begin
            if(TAKEN_BRANCH == 0) // Disable write if branch taken
               case(MEM_WB_Type)
                    RR_ALU: regi[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUout; //rd
                    RM_ALU: regi[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUout; //rt
                    LOAD:   regi[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD; //rt
                    HALT:   HALTED <= #2 1'b1;
               endcase 
         end                                
endmodule