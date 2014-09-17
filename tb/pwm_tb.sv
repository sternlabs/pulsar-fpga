`default_nettype none
`timescale 1 ns / 100 ps

module pwm_tb;

   logic clk;
   logic rst;
   logic [1:0] pwm_addr;
   logic [3:0] pwm_data;
   logic       latch_mem;
   logic [3:0] pwm_out;

   logic [3:0] thres_mem[0:2] = {default:'0};

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
   pwm_data <= thres_mem[pwm_addr];
end


initial begin
   #50;
   @(posedge latch_mem);
   thres_mem  = '{ 'b1001,
                   'b1011,
                   'b0101 };
end


endmodule
