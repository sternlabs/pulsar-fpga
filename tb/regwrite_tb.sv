`timescale 1 ns / 100 ps

module regwrite_tb;

localparam width = 5;
localparam num_reg = 3;
localparam addr_width = $clog2(num_reg);

   logic clk;
   logic rst;

   logic [width-1:0] data_in;
   logic             data_ready;
   logic             new_transfer;
   logic             transfer_done;

   logic [addr_width-1:0] write_addr;
   logic [width-1:0]      write_data;
   logic                  write_enable;
   logic                  write_done;


regwrite #(.width(width), .num_reg(num_reg)) dut(.*);


initial
  #1000 $finish;

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


task transfer(int length);
   $display("%t: starting transfer of length %0d", $time, length);
   @(posedge clk);
   new_transfer = 1;
   @(posedge clk);
   new_transfer = 0;

   repeat (length) begin
      data_in  = $random();
      $display("%t: transfer => %x", $time, data_in);
      repeat (2) @(posedge clk);
      data_ready  = 1;
      @(posedge clk);
      data_ready  = 0;
      @(posedge clk);
   end
   transfer_done  = 1;
   @(posedge clk);
   transfer_done  = 0;
   @(posedge clk);
endtask


always_ff @(posedge clk) begin
   if (write_enable) begin
      $display("%t: write [%x] <= %x", $time, write_addr, write_data);
   end

   if (write_done) begin
      $display("%t: write done", $time);
   end
end


initial begin
   data_ready     = 0;
   new_transfer   = 0;
   transfer_done  = 0;
end

initial begin
   #50 transfer(2);
   #50 transfer(0);
   #50 transfer(5);
end

endmodule
