`timescale 1ns/1ns
/* Test Module designed to read the instructions from a .mem file containing the 32-bit uPower instructions
   in binary
*/
module read_instructions(instruction, program_counter);

    input [31:0] program_counter;
    output reg [31:0] instruction;

    reg [31:0] instructions [5:0];     //set to the number of instructions in the file

    initial begin
        $readmemb("instructions.mem", instructions, 0, 5);
    end

    always @ (program_counter) begin
        instruction = instructions[program_counter];
    end

endmodule

module read_instructions_tb();
    reg [31:0] program_counter;
    wire [31:0] instruction;

    read_instructions instructionReader(
        .program_counter(program_counter),
        .instruction(instruction)
    );

    initial begin

        //first instruction
        program_counter = 32'b0;
        #10;

        //second instruction
        program_counter = program_counter + 1;
        #10;

        //third instruction
        program_counter = program_counter + 1;
        #10;

        //fourth instruction
        program_counter = program_counter + 1;
        #10;

        //fifth instruction
        program_counter = program_counter + 1;
        #10;

        //sixth instruction
        program_counter = program_counter + 1;
        #10;
    end

    initial begin
        $dumpfile("Read_instructions_tb.vcd");
        $dumpvars(0,read_instructions_tb);
    end
endmodule