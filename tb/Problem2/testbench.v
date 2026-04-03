//Q.2: LOAD a word stored in memory location 120, add 45 to it, and store the result in memory location 121 .

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
    forever #10 clk1 = ~clk1;
end

initial begin
    clk2 = 0;
    #5 forever #10 clk2 = ~clk2;
end

// Initialize program
initial begin
    for(i = 0; i < 32; i = i + 1)
        mips.Reg[i] = i;

    for(i = 0; i < 1024; i = i + 1)
        mips.MEM_OUT[i] = 0;

    #2;

    mips.MEM_OUT[0] = 32'h28010078; // ADDI R1, R0, 120
    mips.MEM_OUT[1] = 32'h0c631800; // NOP
    mips.MEM_OUT[2] = 32'h0c631800; // NOP
    mips.MEM_OUT[3] = 32'h0c631800; // NOP 
    mips.MEM_OUT[4] = 32'h20220000; // LW R2, 0(R1)
    mips.MEM_OUT[5] = 32'h0c631800; // NOP
    mips.MEM_OUT[6] = 32'h0c631800; // NOP
    mips.MEM_OUT[7] = 32'h0c631800; // NOP 
    mips.MEM_OUT[8] = 32'h2842002d; // ADDI R2, R2, 45
    mips.MEM_OUT[9] = 32'h0c631800; // NOP
    mips.MEM_OUT[10]= 32'h0c631800; // NOP
    mips.MEM_OUT[11]= 32'h0c631800; // NOP 
    mips.MEM_OUT[12] = 32'h24220001; // SW R2, 1(R1)
    mips.MEM_OUT[13] = 32'h0c631800; // NOP
    mips.MEM_OUT[14] = 32'hfc000000; // HLT

      mips.MEM_OUT[120] = 85;
        end
    initial begin
    #400;   
          $display("MEM_OUT[120]: %4d MEM_OUT[121]: %4d", mips.MEM_OUT[120],mips.MEM_OUT[121]);
    end

initial begin
        $dumpfile("mips32_top.vcd");
        $dumpvars(0, mips32_tb);
        #800 $finish;
    end
endmodule