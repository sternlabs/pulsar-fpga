`timescale 1 ns / 100 ps

module mux_tb;

localparam width = 5;
localparam num_reg = 3;
localparam addr_width = $clog2(num_reg);

   typedef logic [width-1:0] elem_t;
   typedef logic [addr_width-1:0] addr_t;

   logic clk;
   logic rst;
   addr_t write_addr;
   elem_t write_data;
   logic  write_enable;
   logic  write_done;
   addr_t read_addr;
   elem_t read_data;
   logic  read_latch;


mux #(.width(width), .num_reg(num_reg)) dut(.*);


initial
  #1500 $finish;

initial begin
   clk     = 0;
   rst     = 0;

   #5 rst  = 1;
   @(posedge clk);
   rst  = 0;
end

initial begin
   #10;
   forever
     #10 clk++;
end


initial begin
   write_addr    = 0;
   write_data    = 0;
   write_enable  = 0;
   write_done    = 0;
   read_addr     = 0;
   read_latch    = 0;
end

initial begin
   automatic int a  = 0;
   #20;
   @(posedge clk);
   forever begin
      read_addr   = a;
      read_latch  = (a == 0);
      a++;
      if (a == num_reg)
        a  = 0;
      @(posedge clk);
      $display("%t: read [%x] <= %x", $time, read_addr, read_data);
   end
end


task write(int length);
   @(posedge clk);
   $display("%t: writing length %0d", $time, length);
   for (int a = 0; a < length; ++a) begin
      repeat (4) @(posedge clk);
      write_addr    = a;
      write_data    = $random();
      $display("%t: writing [%x] = > %x", $time, write_addr, write_data);
      write_enable  = 1;
      @(posedge clk);
      write_enable  = 0;
   end
   write_done = 1;
   @(posedge clk);
   write_done  = 0;
   @(posedge clk);
endtask


initial begin
   #50 write(num_reg);
   #50 write(num_reg);
   #50 write(num_reg);
end

endmodule
