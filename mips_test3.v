// Example 3 (factorial) for your mips CPU
module mips_test_ex3;

    reg clk1, clk2;
    integer k;

    // DUT
    mips uut (clk1, clk2);

    // Generate two-phase clock
    initial begin
        clk1 = 0; clk2 = 0;
        repeat (80) begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end

    initial begin
        // Initialise registers like in book: Reg[k] = k
        for (k = 0; k < 32; k = k + 1)
            uut.regbank[k] = k;

        // Program (factorial of N at Mem[200], result to Mem[198])
        // 0: ADDI R10,R0,200
        // 1: ADDI R2,R0,1
        // 2: OR   R20,R20,R20      ; dummy
        // 3: LW   R3,0(R10)
        // 4: OR   R20,R20,R20      ; dummy
        // 5: MUL  R2,R2,R3         ; Loop:
        // 6: ADDI R3,R3,-1         ; R3 = R3 - 1  (REPLACES SUBI)
        // 7: OR   R20,R20,R20      ; dummy
        // 8: BNEQZ R3,Loop         ; offset -4
        // 9: SW   R2,-2(R10)       ; Mem[198] = R2
        //10: HLT

        uut.mem[0]  = 32'h280A00C8; // ADDI R10,R0,200
        uut.mem[1]  = 32'h28020001; // ADDI R2,R0,1
        uut.mem[2]  = 32'h0E94A000; // OR   R20,R20,R20 -- dummy
        uut.mem[3]  = 32'h21430000; // LW   R3,0(R10)
        uut.mem[4]  = 32'h0E94A000; // OR   R20,R20,R20 -- dummy
        uut.mem[5]  = 32'h14431000; // MUL  R2,R2,R3
        uut.mem[6]  = 32'h2863FFFF; // ADDI R3,R3,-1   (NEW: replaces SUBI)
        uut.mem[7]  = 32'h0E94A000; // OR   R20,R20,R20 -- dummy
        uut.mem[8]  = 32'h3460FFFC; // BNEQZ R3,Loop   (offset -4)
        uut.mem[9]  = 32'h2542FFFE; // SW   R2,-2(R10) ; Mem[198]
        uut.mem[10] = 32'hFC000000; // HLT

        // Data: N = 7 at Mem[200]
        uut.mem[200] = 7;  // factorial(7) = 5040

        // Control init
        uut.pc           = 0;
        uut.halted       = 0;
        uut.taken_branch = 0;

        // Let it run long enough
        #2000;
        $display("Example 3 (factorial):");
        $display("Mem[200] = %2d, Mem[198] = %6d",
                 uut.mem[200], uut.mem[198]);
    end

    // VCD + monitor
    initial begin
        $dumpfile("mips_ex3.vcd");
        $dumpvars(0, mips_test_ex3);
        $monitor("time=%0t  R2=%0d  R3=%0d",
                 $time, uut.regbank[2], uut.regbank[3]);
        #3000 $finish;
    end

endmodule



