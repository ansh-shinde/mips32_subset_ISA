// testbench for your mips(clk1, clk2) CPU
module test_mips32;

    reg clk1, clk2;
    integer k;

    // DUT instance (your CPU)
    mips uut (clk1, clk2);

    // Generate two–phase clock
    initial begin
        clk1 = 0; clk2 = 0;
        repeat (20) begin
            #5  clk1 = 1;  #5 clk1 = 0;
            #5  clk2 = 1;  #5 clk2 = 0;
        end
    end

    // Stimulus + program load
    initial begin
        // init register file
        for (k = 0; k < 32; k = k + 1)
            uut.regbank[k] = 0;

        // init control signals
        uut.pc           = 0;
        uut.halted       = 0;
        uut.taken_branch = 0;

        // load program into instruction memory
        //  ADDI R1, R0, 10
        //  ADDI R2, R0, 20
        //  ADDI R3, R0, 25
        //  OR   R7, R7, R7   (dummy, to fill pipeline)
        //  OR   R7, R7, R7   (dummy)
        //  ADD  R4, R1, R2
        //  OR   R7, R7, R7   (dummy)
        //  ADD  R5, R4, R3
        //  HLT
        uut.mem[0] = 32'h2801000A;  // ADDI R1, R0, 10
        uut.mem[1] = 32'h28020014;  // ADDI R2, R0, 20
        uut.mem[2] = 32'h28030019;  // ADDI R3, R0, 25
        uut.mem[3] = 32'h0CE77800;  // OR   R7, R7, R7  (dummy)
        uut.mem[4] = 32'h0CE77800;  // OR   R7, R7, R7  (dummy)
        uut.mem[5] = 32'h00222000;  // ADD  R4, R1, R2
        uut.mem[6] = 32'h0CE77800;  // OR   R7, R7, R7  (dummy)
        uut.mem[7] = 32'h00832800;  // ADD  R5, R4, R3
        uut.mem[8] = 32'hFC000000;  // HLT

        // wait for pipeline to finish
        #280;
        $display("----- Register dump -----");
        for (k = 0; k < 6; k = k + 1)
            $display("R%0d = %0d", k, uut.regbank[k]);

    end

    // VCD dump for GTKWave
    initial begin
        $dumpfile("mips.vcd");
        $dumpvars(0, test_mips32);
        #300 $finish;
    end

endmodule
