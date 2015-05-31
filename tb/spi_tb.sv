`timescale 1 ns / 100 ps

module spi_tb;
   logic        nCS;
   logic        SCK;
   logic        MOSI;

   logic        clk;
   logic        reset;
   logic [7:0]  shiftreg;
   logic        data_ready;
   logic        new_transfer;
   logic        transfer_done;

spi_slave #(.width(8)) dut(.*);


task spi_xfer(int length);
   automatic logic [7:0] mosi_out;

   nCS  = 0;
   #4;
   repeat (length) begin
      mosi_out   = $random();
      $display("%d: spi => %x", $time, mosi_out);

      for (int b = 7; b >= 0; --b) begin
         MOSI = mosi_out[b];
         #50;
         SCK  = 1;
         #50;
         SCK  = 0;
      end
   end
   #4;
   nCS  = 1;
   #5;
endtask


initial
  #10000 $finish;


initial begin
   clk        = 0;
   reset      = 0;

   #5 reset   = 1;
   @(posedge clk);
   reset = 0;
end

initial begin
   #10;
   forever
     #10 clk++;
end

always_ff @(posedge clk) begin
   if (new_transfer) begin
      $display("%d: new transfer", $time);
   end

   if (data_ready) begin
      $display("%d: sys <= %x", $time, shiftreg);
   end
end



initial begin
   nCS        = 1;
   SCK        = 0;
   MOSI       = 0;
end

initial begin
   #200 spi_xfer(1);
   #30 spi_xfer(2);
   #30 spi_xfer(1);
end


endmodule
