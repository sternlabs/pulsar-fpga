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

localparam pwm_bits = $clog2(num_pwm);
localparam spi_data_bits = roundup8($clog2(pwm_width));
localparam spi_width = spi_data_bits + roundup8(pwm_bits);

   logic [spi_width-1:0]    spi_data;
   logic                    spi_valid;

   logic [pwm_width-1:0]    thres [num_pwm-1:0];


always_ff @(posedge clk or posedge rst)
  if (rst)
    thres <= {default:'0};
  else
     if (spi_valid)
       thres[spi_data[spi_width-1:spi_data_bits]] <= spi_data[pwm_width-1:0];


spi_slave #(.width(spi_width)) spi(.data_ready(spi_valid), .shiftreg(spi_data), .reset(rst), .*);

pwm #(.pwm_width(pwm_width), .num_pwm(num_pwm)) pwm_i(.thres(thres), .*);

endmodule
