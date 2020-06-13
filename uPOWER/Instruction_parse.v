
`timescale 1ns/1ns
/* Module designed to read the instruction and assign the various
   components of the instruction to suitable variables depending on the format
*/

module ins_parse(
    output wire [5:0] opcode, 
    output reg [4:0] rs, rt, rd, bo, bi, 
    output reg aa, lk, rc, oe,
    output reg [9:0] xox,
    output reg [8:0] xoxo, 
    output reg [15:0] si, 
    output reg [13:0] bd, ds,
    output reg [1:0] xods, 
    output reg [23:0] li,
    input [31:0] instruction, p_count
);

    assign opcode = instruction[31:26];

    always @(instruction) 
    begin

        //XO
        if(opcode == 6'd31 & (instruction[9:1] == 9'd266 | instruction[9:1] == 9'd40))
        begin
            rd = instruction[25:21];
            rt = instruction[20:16];
            rs = instruction[15:11];
            oe = instruction[10];
            xoxo = instruction[9:1];
            rc = instruction[0];
        end

        //X
        else if(opcode == 6'd31)
        begin
            rd = instruction[25:21];
            rt = instruction[20:16];
            rs = instruction[15:11];
            xox = instruction[10:1];
            rc = instruction[0];
        end

        //D
        else if(opcode == 6'd14 | opcode == 6'd15 | opcode == 6'd28 | opcode == 6'd24 | opcode == 6'd26 | opcode == 6'd32 | opcode == 6'd36 | opcode == 6'd37 |opcode == 6'd40 | opcode == 6'd42 |opcode == 6'd44 |opcode == 6'd34 |opcode == 6'd38)
        begin
            rd = instruction[25:21];
            rt = instruction[20:16];   
            si = instruction[15:0];
        end

        //B
        else if(opcode == 6'd19)
        begin
            bo = instruction[25:21];
            bi = instruction[20:16];
            bd = instruction[15:2];
            aa = instruction[1];
            lk = instruction[0];
        end

        //I
        else if(opcode == 6'd18)
        begin
            li = instruction[25:2];
            aa = instruction[1];
            lk = instruction[0];
        end

        //DS
        else
        begin
            rd = instruction[25:21];
            rt = instruction[20:16];
            ds = instruction[15:2];
            xods = instruction[1:0];
        end
    end
endmodule

module ins_parsetb();
    wire [5:0] opcode;
    wire [4:0] rs, rt, rd, bo, bi;
    wire aa, lk, rc, oe;
    wire [9:0] xox;
    wire [8:0] xoxo; 
    wire [15:0] si; 
    wire [13:0] bd, ds;
    wire [1:0] xods;
    wire [23:0] li;
    reg [31:0] instruction, p_count;

    ins_parse instructionParser(
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .bo(bo),
        .bi(bi),
        .aa(aa),
        .lk(lk),
        .rc(rc),
        .oe(oe),
        .xox(xox),
        .xoxo(xoxo),
        .si(si),
        .bd(bd),
        .ds(ds),
        .xods(xods),
        .li(li),
        .instruction(instruction),
        .p_count(p_count)
    );

    initial
    begin
        //add $1, $2, $3, - XO 
        instruction = 32'b01111100001000100001101000010100;
        #10;

        //and $3, $4, $5 - X
        instruction = 32'b01111100100000110010100000111000;
        #10;

        //xori $2, $6, 8 - D
        instruction = 32'b01101000110000100000000000001000;
        #10;

        //bc $4, $5, 0x0fa5 - B
        instruction = 32'b01001100000001010011111010010100;
        #10;

        //ba 0x0123 - I
        instruction = 32'b01001000000000000000010010001110;
        #10;

        //ld $2, 5($4) - DS
        instruction = 32'b11101000010001000000000000010100;
        #10;

    end

    initial begin
        $dumpfile("ins_parsetb.vcd");
        $dumpvars(0,ins_parsetb);
    end
endmodule