module mips(clk1,clk2);
input clk1,clk2;
reg [31:0] pc, ncp, ir, if_id_ir, if_id_npc;
reg [31:0] id_ex_npc, id_ex_a, id_ex_b, id_ex_imm, id_ex_ir;
reg [2:0] id_ex_type, ex_mem_type, mem_wb_type;
reg [31:0] ex_mem_aluout, ex_mem_b, ex_mem_ir;
reg [31:0] mem_wb_lmd, mem_wb_aluout, mem_wb_ir;
reg ex_mem_cond;

reg [31:0]regbank[0:31];                       //reg bank 
reg [31:0]mem[0:1023];                   //data memory

parameter ADD=6'b000000,SUB=6'b000001,AND=6'b000010,OR=6'b000011,SLT=6'b000100,MUL=6'b000101,
         HLT=6'b111111,LW=6'b001000,SW=6'b001001,ADDI=6'b001010,SUBI=001011,SLTI=6'b001100,
         BNEQZ=6'b001101,BEQZ=6'b001110;
         
parameter rr_alu=3'b000, rm_alu=3'b001, load=3'b010, store=3'b011, branch=3'b100, halt=3'b101;

reg halted;
reg taken_branch;

always@(posedge clk1)   // IR stage
if(halted==0)
begin
if(((ex_mem_ir[31:26]==BEQZ) && (ex_mem_cond==1'b1)) || ((ex_mem_ir[31:26]==BNEQZ) && (ex_mem_cond==1'b0)))
begin
if_id_ir <= mem[ex_mem_aluout];
taken_branch <= 1'b1;
if_id_npc <= ex_mem_aluout+1;
pc <= ex_mem_aluout+1;
end
else
begin
if_id_ir <= mem[pc];
if_id_npc <= pc+1;
pc <= pc+1;
end
end

always@(posedge clk2) // ID stage
if(halted==0)
begin
if(if_id_ir[25:21]==5'b00000)
id_ex_a <= 0;
else id_ex_a <= regbank[if_id_ir[25:21]]; //rs

if(if_id_ir[20:16]==5'b00000)
id_ex_b <=0;
else id_ex_b <= regbank[if_id_ir[20:16]]; //rt

id_ex_npc <= if_id_npc;
id_ex_ir <= if_id_ir;
id_ex_imm <= {{16{if_id_ir[15]}},{if_id_ir[15:0]}};

case(if_id_ir[31:26])
ADD,SUB,MUL,OR,AND,SLT : id_ex_type <= rr_alu;
ADDI,SUBI,SLTI         : id_ex_type <= rm_alu;
LW                     : id_ex_type <= load;
SW                     : id_ex_type <= store;
BEQZ,BNEQZ             : id_ex_type <= branch;
HLT                    : id_ex_type <= halt;
default: id_ex_type <= halt;
endcase
end

always@(posedge clk1)   // EX
if(halted==0)
begin
ex_mem_type <= id_ex_type;
ex_mem_ir <= id_ex_ir;
taken_branch <= 0;

case(id_ex_type)
rr_alu:begin
       case(id_ex_ir[31:26])
       ADD: ex_mem_aluout <= id_ex_a + id_ex_b;
       SUB: ex_mem_aluout <= id_ex_a - id_ex_b;
       MUL: ex_mem_aluout <= id_ex_a * id_ex_b;
       AND: ex_mem_aluout <= id_ex_a & id_ex_b;
       OR : ex_mem_aluout <= id_ex_a | id_ex_b;
       SLT: ex_mem_aluout <= id_ex_a < id_ex_b;
       default: ex_mem_aluout <= 32'bxxxxxxxx;
       endcase
       end
rm_alu:begin
       case(id_ex_ir[31:26])
       ADDI: ex_mem_aluout <= id_ex_a + id_ex_imm;
       SUBI: ex_mem_aluout <= id_ex_a - id_ex_imm;
       SLTI: ex_mem_aluout <= id_ex_a < id_ex_imm; 
       default: ex_mem_aluout <= 32'bxxxxxxxx;
       endcase
       end
load,store:begin
           ex_mem_aluout <= id_ex_a + id_ex_imm;
           ex_mem_b      <= id_ex_b;
           end
branch:begin
       ex_mem_aluout <= id_ex_npc + id_ex_imm;
       ex_mem_cond   <= (id_ex_a==0);
       end
endcase
end

always@(posedge clk2)
if(halted==0)
begin
mem_wb_type <= ex_mem_type;
mem_wb_ir   <= ex_mem_ir;
case(ex_mem_type)
rr_alu, rm_alu : mem_wb_aluout <= ex_mem_aluout;
load           : mem_wb_lmd <= mem[ex_mem_aluout];
store          : if(taken_branch==0)   // disable write
                 mem[ex_mem_aluout] <= ex_mem_b;
endcase
end

always@(posedge clk2)   //WB stage
begin
if(taken_branch==0)
case(mem_wb_type)
rr_alu : regbank[mem_wb_ir[15:11]] <= mem_wb_aluout;  //rd
rm_alu : regbank[mem_wb_ir[20:16]] <= mem_wb_aluout;  //rt
load   : regbank[mem_wb_ir[20:16]] <= mem_wb_lmd;     //rt
halt   : halted <= 1'b1;
endcase
end

endmodule


 
                 
 

