module test_mips32;

    reg clk1, clk2;
    integer k;

    // DUT
    mips uut (clk1, clk2);

    // Generate 2-phase clock
    initial begin
        clk1 = 0; clk2 = 0;
        repeat (50) begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end

    initial begin
        // initialize registers
        for (k = 0; k < 32; k = k + 1)
            uut.regbank[k] = 0;

        uut.pc           = 0;
        uut.halted       = 0;
        uut.taken_branch = 0;

        //----------------------------
        // Load Program Instructions
        //----------------------------

        // ADDI R1, R0, 120
        uut.mem[0] = 32'h28010078;

        // dummy instruction (OR R3,R3,R3)
        uut.mem[1] = 32'h0C631800;

        // LW R2, 0(R1)
        uut.mem[2] = 32'h20220000;

        // dummy instruction
        uut.mem[3] = 32'h0C631800;

        // ADDI R2, R2, 45
        uut.mem[4] = 32'h2842002D;

        // dummy instruction
        uut.mem[5] = 32'h0C631800;

        // SW R2, 1(R1)
        uut.mem[6] = 32'h24220001;

        // HLT
        uut.mem[7] = 32'hFC000000;

        //----------------------------
        // Initialize data memory
        //----------------------------
        uut.mem[120] = 85;   // memory location 120 contains value 85

        // wait for MIPS pipeline to finish
        #500;
        $display("Mem[120] = %0d", uut.mem[120]);
        $display("Mem[121] = %0d", uut.mem[121]);
    end

    initial begin
        $dumpfile("mips.vcd");
        $dumpvars(0, test_mips32);
        #600 $finish;
    end

endmodule


