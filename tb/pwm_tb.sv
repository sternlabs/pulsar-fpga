`default_nettype none
`timescale 1 ns / 100 ps

module pwm_tb;

   logic clk;
   logic rst;
   logic [3:0] new_thres;
   logic [1:0] sel_thres;
   logic       set_thres = 0;
   logic [3:0] pwm_out;

pwm #(.pwm_width(4), .num_pwm(4)) dut(.*);

initial begin
   $dumpfile("pwm_tb.vcd");
   $dumpvars(0, pwm_tb);
end

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
   #50;
   new_thres  = 5;
   sel_thres  = 0;
   set_thres  = 1;
end


endmodule
