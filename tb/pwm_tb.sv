`default_nettype none
`timescale 1 ns / 100 ps

module pwm_tb;

   logic clk;
   logic rst;
   logic [2:0] thres [3:0];
   logic [3:0] pwm_out;

pwm #(.pwm_width(3), .num_pwm(4)) dut(.*);

// initial begin
//    $dumpfile("pwm_tb.vcd");
//    $dumpvars(0);
// end

initial
  #10000 $finish;

initial begin
   rst      = 1;
   #15 rst  = 0;
end

initial begin
   clk  = 0;
   #10;
   forever
     #10 clk++;
end

initial begin
   thres = '{ 0, 0, 0, 0 };
   #50;
   thres  = '{ 2, 4, 7, 1 };
end


endmodule
