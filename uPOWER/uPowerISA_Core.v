/* uPowerISA Core Module is the centre of all operations that handles all the operations and instantiates
all the necessary modules
*/
`include "Control_Unit.v"
`include "Instruction_parse.v"
`include "ALU64Bit.v"
`include "Read_Instructions.v"
`include "Read_Memory.v"
`include "Read_Registers.v"

module uPower_core(clock);

input clock; //Execution happens only at positive level-transition (edge sensitive)

//Program counter

reg [31:0] PC = 32'b0;

//Instruction
wire [31:0] instruction;

//Parse instruction
wire [5:0] opcode;
wire [4:0] rs,rt,rd,bo,bi;
wire [8:0] xoxo;
wire [9:0] xox;
wire rc,aa,lk,oe;
wire [13:0] bd,ds;
wire [15:0] si;
wire [23:0] li;
wire [1:0] xods;

//Signals

wire RegRead, RegWrite, RegDst, MemRead, MemWrite, Branch;

//Register contents
wire [63:0] write_data, rs_content, rt_content, memory_read_data;

//Instantiating all necessary modules
read_instructions InstructionMemory(instruction, PC);

ins_parse Parse(opcode, rs, rt, rd, bo, bi, aa, lk, rc, oe, xox, xoxo, si, bd, ds, xods, li, instruction, PC);

control_unit Signals(RegRead, RegWrite, MemRead, MemWrite, Branch, opcode, xox, xoxo, xods);

ALU64bit ALU(write_data, Branch, opcode, rs, rt, bo, bi, si, ds, xox, xoxo, aa, xods);

read_data_memory MainMemory(memory_read_data, write_data, rs_content, opcode, MemWrite, MemRead);

read_registers Registers(rs_content, rt_content,  write_data, rs, rt, rd, opcode, RegRead, RegWrite, RegDst, clock);

// PC operations - The next instruction is read only when the clock is at positive edge

always @(posedge clock) 
 begin
     if(opcode == 6'd18)
       PC = {{8{1'b0}},li};
     else if(write_data == 0 & Branch == 1)
       PC = PC + 1 + $signed(bd);
     else 
       PC = PC +1 ;
 end

endmodule