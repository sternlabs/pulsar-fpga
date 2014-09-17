module top
  #(
    parameter pwm_width = 16,
    parameter num_pwm = 12
    )
(
 input wire                 nCS,
 input wire                 SCK,
 input wire                 MOSI,

 input wire                 clk,
 input wire                 rst,

 output logic [num_pwm-1:0] pwm_out
 );

function integer roundup8;
   input integer            bits;
   begin
      return (bits + 7) / 8 * 8;
   end
endfunction

localparam pwm_bits = $clog2(pwm_width);
localparam spi_data_bits = roundup8(pwm_bits);
localparam spi_width = spi_data_bits + roundup8(num_pwm);

   logic [spi_width-1:0]    spi_data;
   logic                    spi_valid;

   logic                    latch_mem;
   logic [pwm_bits-1:0]     pwm_addr;
   logic [num_pwm-1:0]      pwm_data;


spi_slave #(.width(spi_width)) spi(.data_ready(spi_valid), .shiftreg(spi_data), .reset(rst), .*);


   logic [pwm_bits-1:0]     spi_thres_id;
   logic [num_pwm-1:0]      spi_thres_val;

assign spi_thres_id = spi_data[spi_width-1:spi_data_bits];
assign spi_thres_val = spi_data[pwm_width-1:0];

thresmem
  #(.pwm_width(pwm_width), .num_pwm(num_pwm))
mem(.write_enable(spi_valid), .waddr(spi_thres_id), .wdata(spi_thres_val),
    .raddr(pwm_addr), .rdata(pwm_data), .*);

pwm #(.pwm_width(pwm_width), .num_pwm(num_pwm)) pwm_i(.*);

endmodule
