`timescale 1ns/1ns

/* Module designed to read the instruction and assign the various
   components of the instruction to suitable variables depending on the format
*/
module ins_parser(
    output wire [5:0] opcode,
    output reg [4:0] rs, rt, rd, shamt, 
    output reg [5:0] funct,
    output reg[15:0] immediate,
    output reg [25:0] address,
    input [31:0] instruction, p_count
);

    assign opcode = instruction[31:26];
	
    always @(instruction) begin
        if(opcode == 6'h0) 
        begin        //R-type 
            shamt = instruction[10:6];
            rd = instruction[15:11];
            rt = instruction[20:16];
            rs = instruction[25:21];
            funct = instruction[5:0];
        end
        else if(opcode == 6'h2 | opcode == 6'h3) 
        begin   // J-type
            address = instruction[25:0];
        end
        else 
        begin                               // I-type
            rt = instruction[20:16];
            rs = instruction[25:21];
            immediate = instruction[15:0];
        end
    end
	
endmodule

module ins_parsertb();
    wire [5:0] opcode;
    wire [4:0] rs, rt, rd, shamt; 
    wire [5:0] funct;
    wire [15:0] immediate;
    wire [25:0] address;
    reg [31:0] instruction, p_count;  //check the data type

    ins_parser instructionParser(
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .funct(funct),
        .immediate(immediate),
        .address(address),
        .instruction(instruction),
        .p_count(p_count)
    );

    initial
    begin

        //sub $2, $8, $3 - R type instruction
        instruction = 32'b00000001000000110001000000100010;
        #10;

        //addi $6, $1, #10 - I type instruction
        instruction = 32'b00100000001001100000000000001010; 
        #10;

        //J 257 - J type instruction
        instruction = 32'b00001000000000000000000100000001;
        #10;

        //add $t0, $s1, $s2 - R type instruction
        instruction = 32'b00000010001100100100000000100000;
        #10;

        //jal 563 - J type instruction
        instruction = 32'b00001100000000000000001000110011;
        #10;

        //ori $8, $0, 0x0fa5 - I type instruction
        instruction = 32'b00110100000010000000111110100101;
        #10;

        //beq $4, $5, 7 - I type instruction
        instruction = 32'b00010000100001010000000000000111;
        #10;

        //lw $26, 3($30) - I type instruction
        instruction = 32'b10001111110110100000000000000011;
        #10;

        //sw $2,3($5) - I type instruction
        instruction = 32'b10101100101000100000000000000011;
        #10;
    end

    initial begin
        $dumpfile("Ins_parsetb.vcd");
        $dumpvars(0,ins_parsertb);
    end
endmodule