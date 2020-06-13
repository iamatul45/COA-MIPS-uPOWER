// uPowerISA test bench - To drive and simulate the entire MIPS ALU 

`include "uPowerISA_Core.v"

module uPower_testbench();

reg clock;
wire result;

uPower_core test(clock);
initial clock = 0;

initial 
 begin
#100 clock=~clock; #100 clock=~clock;
#100 clock=~clock; #100 clock=~clock;
#100 clock=~clock; #100 clock=~clock;
#100 clock=~clock; #100 clock=~clock;
#100 clock=~clock; #100 clock=~clock;
#100 clock=~clock; #100 clock=~clock;
#100 clock=~clock; #100 clock=~clock;
#100 clock=~clock; #100 clock=~clock;
#100 clock=~clock; #100 clock=~clock;
 end

initial begin
  $dumpfile("uPower_testbench.vcd"); 
  $dumpvars(0, uPower_testbench);
end

endmodule