//==============================================================================
// Module Name : mips
// Project     : 32-bit Pipelined MIPS Processor
// Author      : Ansh Shinde
//
// Description :
// A 32-bit five-stage pipelined MIPS processor implemented in Verilog HDL.
//
// Pipeline Stages:
// 1. IF  - Instruction Fetch
// 2. ID  - Instruction Decode / Register Fetch
// 3. EX  - Execute / Address Calculation
// 4. MEM - Memory Access
// 5. WB  - Write Back
//
// Features:
// - Five-stage instruction pipeline
// - Register-register ALU instructions
// - Register-immediate ALU instructions
// - Load and Store instructions
// - Conditional Branch instructions
// - Two-phase clocking scheme
// - Unified instruction/data memory
//
// Clocking Scheme:
// clk1 -> IF and EX stages
// clk2 -> ID, MEM and WB stages
//
//==============================================================================

module mips(clk1,clk2);

input clk1,clk2;


//==============================================================================
// Pipeline Registers
//==============================================================================

// IF/ID Pipeline Registers
reg [31:0] pc, ncp, ir, if_id_ir, if_id_npc;

// ID/EX Pipeline Registers
reg [31:0] id_ex_npc, id_ex_a, id_ex_b, id_ex_imm, id_ex_ir;
reg [2:0] id_ex_type;

// EX/MEM Pipeline Registers
reg [2:0] ex_mem_type;
reg [31:0] ex_mem_aluout, ex_mem_b, ex_mem_ir;
reg ex_mem_cond;

// MEM/WB Pipeline Registers
reg [2:0] mem_wb_type;
reg [31:0] mem_wb_lmd, mem_wb_aluout, mem_wb_ir;


//==============================================================================
// Architectural State Elements
//==============================================================================

// General Purpose Register File (32 x 32)
reg [31:0] regbank[0:31];

// Unified Memory (Instruction + Data Memory)
reg [31:0] mem[0:1023];


//==============================================================================
// Opcode Definitions
//==============================================================================

parameter ADD   = 6'b000000,
          SUB   = 6'b000001,
          AND   = 6'b000010,
          OR    = 6'b000011,
          SLT   = 6'b000100,
          MUL   = 6'b000101,
          HLT   = 6'b111111,
          LW    = 6'b001000,
          SW    = 6'b001001,
          ADDI  = 6'b001010,
          SUBI  = 6'b001011,
          SLTI  = 6'b001100,
          BNEQZ = 6'b001101,
          BEQZ  = 6'b001110;


//==============================================================================
// Instruction Type Encoding
//==============================================================================

parameter rr_alu = 3'b000,   // Register-Register ALU Operations
          rm_alu = 3'b001,   // Register-Immediate ALU Operations
          load   = 3'b010,   // Load Instructions
          store  = 3'b011,   // Store Instructions
          branch = 3'b100,   // Branch Instructions
          halt   = 3'b101;   // Halt Instruction


//==============================================================================
// Processor Control Signals
//==============================================================================

reg halted;          // Processor Halt Flag
reg taken_branch;    // Indicates Branch Taken


//==============================================================================
// Instruction Fetch Stage (IF)
//
// - Fetches instruction from memory.
// - Updates Program Counter.
// - Handles branch redirection.
//==============================================================================

always @(posedge clk1)
if(halted==0)
begin

    // Branch Taken
    if(((ex_mem_ir[31:26]==BEQZ)  && (ex_mem_cond==1'b1)) ||
       ((ex_mem_ir[31:26]==BNEQZ) && (ex_mem_cond==1'b0)))
    begin
        if_id_ir <= mem[ex_mem_aluout];
        taken_branch <= 1'b1;
        if_id_npc <= ex_mem_aluout + 1;
        pc <= ex_mem_aluout + 1;
    end

    // Sequential Execution
    else
    begin
        if_id_ir <= mem[pc];
        if_id_npc <= pc + 1;
        pc <= pc + 1;
    end
end


//==============================================================================
// Instruction Decode Stage (ID)
//
// - Reads source operands from register file.
// - Sign extends immediate.
// - Classifies instruction type.
//==============================================================================

always @(posedge clk2)
if(halted==0)
begin

    // Read Source Register rs
    if(if_id_ir[25:21]==5'b00000)
        id_ex_a <= 0;
    else
        id_ex_a <= regbank[if_id_ir[25:21]];

    // Read Source Register rt
    if(if_id_ir[20:16]==5'b00000)
        id_ex_b <=0;
    else
        id_ex_b <= regbank[if_id_ir[20:16]];

    // Pass Pipeline Information
    id_ex_npc <= if_id_npc;
    id_ex_ir  <= if_id_ir;

    // Sign Extension of Immediate Field
    id_ex_imm <= {{16{if_id_ir[15]}},{if_id_ir[15:0]}};

    // Instruction Classification
    case(if_id_ir[31:26])

        ADD,SUB,MUL,OR,AND,SLT :
            id_ex_type <= rr_alu;

        ADDI,SUBI,SLTI :
            id_ex_type <= rm_alu;

        LW :
            id_ex_type <= load;

        SW :
            id_ex_type <= store;

        BEQZ,BNEQZ :
            id_ex_type <= branch;

        HLT :
            id_ex_type <= halt;

        default:
            id_ex_type <= halt;

    endcase
end


//==============================================================================
// Execute Stage (EX)
//
// - Performs ALU operations.
// - Computes effective memory addresses.
// - Evaluates branch conditions.
//==============================================================================

always @(posedge clk1)
if(halted==0)
begin

    ex_mem_type <= id_ex_type;
    ex_mem_ir   <= id_ex_ir;

    taken_branch <= 0;

    case(id_ex_type)

        // Register-Register Operations
        rr_alu:
        begin
            case(id_ex_ir[31:26])

                ADD : ex_mem_aluout <= id_ex_a + id_ex_b;
                SUB : ex_mem_aluout <= id_ex_a - id_ex_b;
                MUL : ex_mem_aluout <= id_ex_a * id_ex_b;
                AND : ex_mem_aluout <= id_ex_a & id_ex_b;
                OR  : ex_mem_aluout <= id_ex_a | id_ex_b;
                SLT : ex_mem_aluout <= id_ex_a < id_ex_b;

                default:
                    ex_mem_aluout <= 32'bxxxxxxxx;

            endcase
        end


        // Register-Immediate Operations
        rm_alu:
        begin
            case(id_ex_ir[31:26])

                ADDI : ex_mem_aluout <= id_ex_a + id_ex_imm;
                SUBI : ex_mem_aluout <= id_ex_a - id_ex_imm;
                SLTI : ex_mem_aluout <= id_ex_a < id_ex_imm;

                default:
                    ex_mem_aluout <= 32'bxxxxxxxx;

            endcase
        end


        // Load/Store Address Generation
        load,store:
        begin
            ex_mem_aluout <= id_ex_a + id_ex_imm;
            ex_mem_b      <= id_ex_b;
        end


        // Branch Evaluation
        branch:
        begin
            ex_mem_aluout <= id_ex_npc + id_ex_imm;
            ex_mem_cond   <= (id_ex_a==0);
        end

    endcase
end


//==============================================================================
// Memory Access Stage (MEM)
//
// - Performs memory read/write operations.
//==============================================================================

always @(posedge clk2)
if(halted==0)
begin

    mem_wb_type <= ex_mem_type;
    mem_wb_ir   <= ex_mem_ir;

    case(ex_mem_type)

        rr_alu, rm_alu :
            mem_wb_aluout <= ex_mem_aluout;

        load :
            mem_wb_lmd <= mem[ex_mem_aluout];

        store :
            if(taken_branch==0)
                mem[ex_mem_aluout] <= ex_mem_b;

    endcase
end


//==============================================================================
// Write Back Stage (WB)
//
// - Writes results back into register file.
//==============================================================================

always @(posedge clk2)
begin

    if(taken_branch==0)

        case(mem_wb_type)

            rr_alu :
                regbank[mem_wb_ir[15:11]] <= mem_wb_aluout;

            rm_alu :
                regbank[mem_wb_ir[20:16]] <= mem_wb_aluout;

            load :
                regbank[mem_wb_ir[20:16]] <= mem_wb_lmd;

            halt :
                halted <= 1'b1;

        endcase
end

endmodule

 
                 
 

