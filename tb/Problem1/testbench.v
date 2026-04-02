Q.1: Add two numbers stored in registers R1 and R2, and store the result in register R3.
`timescale 1ns/1ps

module mips32_tb;

reg clk1, clk2;
wire [31:0] DATA_OUT;
    integer i;

// Instantiate top module
mips32_top mips(
    .clk1(clk1),
    .clk2(clk2),
    .DATA_OUT(DATA_OUT)
);

// Clock generation
initial begin
    clk1 = 0;
    clk2 = 0;
    forever begin
        #5 clk1 = ~clk1;
        #5 clk2 = ~clk2;
    end
end

// Initialize program
initial begin
    for(i = 0; i < 32; i = i + 1)
        mips.Reg[i] = 0;

    for(i = 0; i < 1024; i = i + 1)
        mips.MEM_OUT[i] = 0;

    #2;

        mips.MEM_OUT[0] = 32'h2801000a; // ADDI R1,R0,10
        mips.MEM_OUT[1] = 32'h28020014; // ADDI R2,R0,20
        mips.MEM_OUT[2] = 32'h28030019; // ADDI R3,R0,25
        mips.MEM_OUT[3] = 32'h0ce77800; // NOP
        mips.MEM_OUT[4] = 32'h0ce77800; // NOP
        mips.MEM_OUT[5] = 32'h00222000; // ADD R4,R1,R2
        mips.MEM_OUT[6] = 32'h0ce77800; // NOP
        mips.MEM_OUT[7] = 32'h0ce77800; // NOP
        mips.MEM_OUT[8] = 32'h00832800; // ADD R5,R4,R3
        mips.MEM_OUT[9] = 32'hfc000000; // HLT
     
        end
    initial begin
    #400;    
        for(i=0; i<6; i=i+1)
            $display("R%0d = %0d", i, mips.Reg[i]);
    end

initial begin
        $dumpfile("mips32_top.vcd");
        $dumpvars(0, mips32_tb);
        #800 $finish;
    end
endmodule