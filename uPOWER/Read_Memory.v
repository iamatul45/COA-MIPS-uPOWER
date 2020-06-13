`timescale 1ns/1ns
module read_data_memory (
    output reg [63:0] read_data,
    input [63:0] address, 
    input [63:0] write_data,
    input [5:0] opcode, 
    input MemWrite, MemRead
);

    reg [63:0] data_mem [255:0];

    initial
    begin
        $readmemb("data.mem", data_mem, 5, 0);
    end

    always @ (address) 
    begin
        if(MemWrite) 
        begin
            //Store byte
            if(opcode == 6'd38)     
            begin
                data_mem[address] = {{56{1'b0}}, write_data[7:0]};
            end

            //Store halfword
            else if(opcode == 6'd44) 
            begin
                data_mem[address] = {{48{1'b0}}, write_data[15:0]};
            end
            
            //Store word
            else if(opcode == 6'd36) 
            begin
                data_mem[address] = {{32{1'b0}}, write_data[31:0]};
            end
            //store word by default
            else 
            begin
                data_mem[address] = write_data;
            end
            // Write the updated contents back to the data_mem file
            $writememb("data.mem", data_mem);            
        end
        else if(MemRead)
        begin
            // read byte
            if(opcode==6'd34)
            begin
                read_data = {{56{1'b0}}, data_mem[address][7:0]};
            end
            // read halfword
            else if(opcode==6'd40)
            begin
                read_data = {{48{1'b0}}, data_mem[address][15:0]};
            end
            // read word
            else if(opcode==6'd32)
            begin
                read_data = {{32{1'b0}}, data_mem[address][31:0]};
            end
            // read word by default
            else
            begin
                read_data = data_mem[address];
            end
        end

    end

    initial 
    begin
        $monitor("opcode : %6b, address : %32b, write data : %32b, read signal : %1b, write signal : %1b, output read data : %32b\n",
        opcode, address, write_data, MemRead, MemWrite, read_data);
    end
endmodule

module read_data_memory_tb();

    wire [63:0] read_data;
    reg [63:0] address;
    reg [63:0] write_data;
    reg [5:0] opcode;
    reg MemWrite, MemRead;

    read_data_memory testerboi(
        .read_data(read_data),
        .address(address),
        .write_data(write_data),
        .opcode(opcode),
        .MemWrite(MemWrite),
        .MemRead(MemRead)
    );

    initial begin

        MemRead = 1'b0;
        MemWrite = 1'b1;

        opcode = 6'd38;
        address = 32'd0;
        write_data = 32'd57321;
        #10;

        opcode = 6'd44;
        address = 32'd13;
        write_data = 32'd0;
        #10;

        opcode = 6'd36;
        address = 32'd1;
        write_data = 32'd1023;
        #10;

        MemRead = 1'b1;
        MemWrite = 1'b0;

        opcode = 6'd34;
        address = 32'd0;
        #10;

        opcode = 6'd40;
        address = 32'd13;
        #10;

        opcode = 6'd32;
        address = 32'd1;
        #10;


    end

    initial begin
        $dumpfile("read_data_memory.vcd"); 
        $dumpvars(0, read_data_memory_tb);
    end

endmodule