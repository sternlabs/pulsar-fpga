`default_nettype none
`timescale 1 ns / 100 ps

module pwm_tb;

   logic clk;
   logic rst;
   logic [1:0] thres_id;
   logic [2:0] thres;
   logic       latch_mem;
   logic [3:0] pwm_out;

   logic [2:0] thres_mem[3:0] = {default:'0};

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

always_ff @(posedge clk)
begin
   thres <= thres_mem[thres_id];
end


initial begin
   #50;
   @(posedge latch_mem);
   thres_mem  = '{ 2, 4, 7, 1 };
end


endmodule
