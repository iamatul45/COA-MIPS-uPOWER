/* Module to read the 64-bit registers and read/write according to the RegWrite an RegRead signals*/

module read_registers(
    output reg [63:0] read_data_1, read_data_2, // The output are two 64-bit binary numbers that contain the data stored in RS and RT
    input [63:0] write_data, // The output are two 32-bit binary numbers that contain the data stored in RS and RT
    input [4:0] rs, rt, rd,  // RS and RT are the read registers and RD (Destination register) is the write register
    input [5:0] opcode,  // 6 bit opcode
    input RegRead, RegWrite, RegDst, clk  // RegRead and RegWrite are signals that indicate whether the instruction needs to read from registers and/or write to a register
);

    reg [63:0] registers [31:0];  //The set of 64 bit registers

    initial 
    begin
        $readmemb("registers.mem", registers);  //Reads all the values stored in the 32 registers
        registers[0]=64'd0;
    end

    always @(write_data)
    begin
        if(RegWrite)
        begin
            /* RegWrite = 0 => Write to RT
               RegWrite = 1 => Write to RD    */
            read_data_1 = 32'dx;
            read_data_2 = 32'dx;
            if (RegDst)
            begin
                if(opcode == 6'd34)     //Load Byte
                    registers[rd] = {{56{1'b0}}, write_data[7:0]};
                else if (opcode == 6'd40)       //Load halfword and Zero
                    registers[rd] = {{48{1'b0}}, write_data[15:0]};
                else if (opcode == 6'd42)       //Load halfword with sign extension
                    registers[rd] = {{48{write_data[15]}}, write_data[15:0]};
                else if(opcode == 6'd32)        //Load word
                    registers[rd] = {{32{1'b0}}, write_data[31:0]};
                else                            //Load doubleword
                    registers[rd] = write_data;
            end
            else
            begin
                if(opcode == 6'd34)             //Load byte
                    registers[rt] = {{56{1'b0}}, write_data[7:0]};
                else if (opcode == 6'd40)       //Load halfword and zero
                    registers[rt] = {{48{1'b0}}, write_data[15:0]};
                else if (opcode == 6'd42)       //Load halfword with sign extension
                    registers[rt] = {{48{write_data[15]}}, write_data[15:0]};
                else if(opcode == 6'd32)        //Load word
                    registers[rt] = {{32{1'b0}}, write_data[31:0]};
                else                            //Load doubleword
                    registers[rt] = write_data;
            end
            //Write back the values in the registers file
            registers[0]=64'd0;
            $writememb("registers.mem", registers);
        end
    end
    
    always @(rs, rt)
    begin
        //Read from registers
        if(RegRead)
        begin
            read_data_1 = registers[rs];
            read_data_2 = registers[rt];
        end
    end

    initial begin
        $monitor("opcode : %6b, read_data_1 : %32b, read_data_2 : %32b, write_data : %32b, rs : %5b, rt : %5b, rd : %5b, RegRead : %1b, RegWrite : %1b, RegDst : %1b\n", opcode, read_data_1, read_data_2, write_data, rs, rt, rd, RegRead, RegWrite, RegDst);
    end

endmodule

module read_registers_tb();
    wire [63:0] read_data_1, read_data_2;
    reg [63:0] write_data;
    reg [4:0] rs, rt, rd;
    reg [5:0] opcode;
    reg RegRead, RegWrite, RegDst, clk;

    read_registers testerboi(
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .write_data(write_data),
        .rs(rs),
        .rt(rt),
        .rd(rd), 
        .opcode(opcode),
        .RegRead(RegRead),
        .RegWrite(RegWrite),
        .RegDst(RegDst),
        .clk(clk)
    );

    initial begin
        RegWrite=0;
        RegRead =1;
        RegDst = 0;
        write_data = 32'd5550123;
        // Read r0 and r11.
        rs = 5'd0;
        rt = 5'd11;
        rd = 5'd14;
        #10;

        RegWrite=1;
        RegRead =0;
        RegDst = 1;

        // LB into r14
        opcode = 6'd34;
        write_data = 32'd5550123;
        #10;

        // LHU into r0
        rt = 5'd0;
        RegDst = 0;
        opcode = 6'd40;
        write_data = 32'd5550123;
        #10;

        // Read r0 and r14.
        RegRead =1;
        RegWrite=0;
        RegDst = 0;
        rs = 5'd0;
        rt = 5'd14;
        #10;

    end

    initial begin
        $dumpfile("read_registers.vcd"); 
        $dumpvars(0, read_registers_tb);
    end


endmodule