`timescale 1 ns / 100 ps

module top_tb;

localparam pwm_width = 5;
localparam num_pwm = 3;

   logic                 nCS;
   logic                 SCK;
   logic                 MOSI;

   logic [num_pwm-1:0]  pwm_out;

top #(.pwm_width(pwm_width), .num_pwm(num_pwm)) dut(.*);


initial
  #20000 $finish;

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


initial begin
   nCS   = 1;
   SCK   = 0;
   MOSI  = 0;
end

initial begin
   #50 spi_xfer(pwm_width);
   #50 spi_xfer(pwm_width * 2);
   #50 spi_xfer(pwm_width);
end

endmodule


module platform
  (
   output logic clk,
   output logic rst
   );

initial begin
   clk     = 0;
   rst     = 1;

   #35;
   @(posedge clk);
   rst = 0;
end

initial begin
   #10;
   forever
     #10 clk++;
end

endmodule
