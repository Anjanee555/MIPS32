`timescale 1ns / 1ps

//Q.1: ADD three numbers 10, 20 and 25 using MIPS32 pipeline
module mips32_tb;

    reg clk1, clk2;
    integer k;

    mips32 mips (.clk1(clk1), .clk2(clk2));

    // Two-phase clock generation
    initial begin
        clk1 = 0; clk2 = 0;
      repeat(40) begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end
  
    // Initialize registers and memory
    initial begin
        for(k=0; k<32; k=k+1) begin
            mips.regi[k] = k;
        end

        mips.mem[0] = 32'h2801000a; // ADDI R1,R0,10
        mips.mem[1] = 32'h28020014; // ADDI R2,R0,20
        mips.mem[2] = 32'h28030019; // ADDI R3,R0,25
        mips.mem[3] = 32'h0ce77800; // NOP
        mips.mem[4] = 32'h0ce77800; // NOP
        mips.mem[5] = 32'h00222000; // ADD R4,R1,R2
        mips.mem[6] = 32'h0ce77800; // NOP
        mips.mem[7] = 32'h0ce77800; // NOP
        mips.mem[8] = 32'h00832800; // ADD R5,R4,R3
        mips.mem[9] = 32'hfc000000; // HLT

        mips.HALTED = 0;
        mips.PC = 0;
        mips.TAKEN_BRANCH = 0;

        #400
        for(k=0; k<6; k=k+1)
            $display("R%0d = %0d", k, mips.regi[k]);
    end

    // Waveform
    initial begin
        $dumpfile("mips.vcd");
        $dumpvars(0, mips32_tb);
        #800 $finish;
    end

endmodule


//________________________________________________________________________________________________________________________

//Q.2: LOAD a word stored in memory location 120, add 45 to it, and store the result in memory location 121 .

`timescale 1ns / 1ps

module mips32_tb;

    reg clk1, clk2;
    integer k;

    mips32 mips (.clk1(clk1), .clk2(clk2));

    // Two-phase clock generation
    initial begin
        clk1 = 0; clk2 = 0;
      repeat(40) begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end
  
    // Initialize registers and memory
    initial begin
        for(k=0; k<32; k=k+1) begin
            mips.regi[k] = k;
        end

      mips.mem[0] = 32'h28010078; // ADDI R1,R0,120
      mips.mem[1] = 32'h0c631800; // NOP
      mips.mem[2] = 32'h20220000; // LW R2,0(R1)
      mips.mem[3] = 32'h0c631800; // NOP
      mips.mem[4] = 32'h2842002d; // ADDI R2,R2,45
      mips.mem[5] = 32'h0c631800; // NOP
      mips.mem[6] = 32'h24220001; // SW R2,1(R1)
      mips.mem[7] = 32'hfc000000; // HLT

      mips.mem[120] = 85;
        mips.HALTED = 0;
        mips.PC = 0;
        mips.TAKEN_BRANCH = 0;

        #500
       
      $display("mem[120]: %4d\n mem[121]: %4d", mips.mem[120],mips.mem[121]);
    end

    // Waveform
    initial begin
        $dumpfile("mips.vcd");
        $dumpvars(0, mips32_tb);
        #600 $finish;
    end

endmodule

//________________________________________________________________________________________________________________________

//Q3: Compute the factorial of a number N stored in memory location 200.The result will be stored in memory location 198.

`timescale 1ns / 1ps

module mips32_tb;

    reg clk1, clk2;
    integer k;

    mips32 mips (.clk1(clk1), .clk2(clk2));

    // Two-phase clock generation
    initial begin
        clk1 = 0; clk2 = 0;
      repeat(50) begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end
  
    // Initialize registers and memory
    initial begin
        for(k=0; k<32; k=k+1) begin
            mips.regi[k] = k;
        end

      mips.mem[0] = 32'h280a00c8; // ADDI R10,R0,200
      mips.mem[1] = 32'h28020001; // ADDI R2,R0,1
      mips.mem[2] = 32'h0e94a000; // NOP
      mips.mem[3] = 32'h21430000; // LW R3,0(R10)
      mips.mem[4] = 32'h0e94a000; // NOP
      mips.mem[5] = 32'h14431000; // LOOP: MUL R2,R2,R3
      mips.mem[6] = 32'h2c630001; // SUBI R3,R3,1
      mips.mem[7] = 32'h0e94a000; // NOP
      mips.mem[8] = 32'h3460fffc; // BNEQZ R3 LOOP
      mips.mem[9] = 32'h2542fffe; // SW R2,-2(R10)
      mips.mem[10] = 32'hfc000000; // HLT

      mips.mem[200] = 9;
        mips.HALTED = 0;
        mips.PC = 0;
        mips.TAKEN_BRANCH = 0;

        #2000
       
      $display("mem[200]: %2d\n mem[198]: %6d", mips.mem[200],mips.mem[198]);
    end

    // Waveform
    initial begin
        $dumpfile("mips.vcd");
        $dumpvars(0, mips32_tb);
      $monitor("R2: %4d",mips.regi[2]);
        #3500 $finish;
    end

endmodule


