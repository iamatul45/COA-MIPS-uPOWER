/* Module to behave like the control unit to set the necessary signals for the execution of an 
   instruction -
   1. RegDst - Which field of the instruction is the register to be written to
   2. RegWrite - Write to register file
   3. RegRead - Read from a register
   4. ALUSrc - The source for the second input to the ALU
   5. PCSrc - Source for PC (next instruction to be executed)
   6. MemRead - Read from the main memory
   7. MemWrite - Write to the main memory
   8. MemToReg - Source of write_data (data to be written to the register file)
   9. Branch -  When a branch/jump instruction is used
*/

module control_unit(
    output reg  RegRead,
                RegWrite,
                MemRead,
                MemWrite,
                Branch,
    input [5:0] opcode,
    input [9:0] xox,
    input [8:0] xoxo, 
    input [1:0] xods
);

    always @(opcode, xoxo, xox, xods)
    begin
        MemRead = 1'b0;
        MemWrite = 1'b0;
        RegRead = 1'b0;
        RegWrite = 1'b0;
        Branch = 1'b0;
    end
    
    always @(opcode, xoxo, xox, xods)
    begin
        //X OR XO Format
        if(opcode == 6'd31) 
        begin
            RegRead = 1'b1;
            RegWrite = 1'b1;
        end

        //D Format - ALU Only 
        else if(opcode == 6'd14 | opcode == 6'd15 |opcode == 6'd28 |opcode == 6'd24 |opcode == 6'd26)
        begin
            RegRead = 1'b1;
            RegWrite = 1'b1;
        end

        //D Format Loads and DS load
        else if(opcode == 6'd58 | opcode == 6'd32 |opcode == 6'd40 |opcode == 6'd42 |opcode == 6'd34)
        begin
            RegRead = 1'b1;
            RegWrite = 1'b1;
            MemRead = 1'b1;
        end

        //D-Format Stores and DS Store
        else if(opcode == 6'd38 |opcode == 6'd44 |opcode == 6'd37 |opcode == 6'd36 |opcode == 6'd62)
        begin
            RegRead = 1'b1;
            MemWrite = 1'b1;
        end

        //Unconditonal Branch
        else if(opcode == 6'd18)
        begin
            Branch = 1'b1;
        end

        //Conditional Branch
        else if(opcode == 6'd19)
        begin
            Branch = 1'b1;
            RegRead = 1'b1;
        end
    end
endmodule