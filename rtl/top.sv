module top
  #(
    parameter pwm_width = 16,
    parameter num_pwm = 2
    )
(
 input logic                nCS,
 input logic                SCK,
 input logic                MOSI,

 input logic                clk,

 output logic [num_pwm-1:0] pwm_out
 );

localparam pwm_bits = $clog2(num_pwm);
localparam pwm_bytes = (pwm_bits + 7) / 8;
localparam spi_width = pwm_width + pwm_bytes * 8;

   logic [spi_width-1:0]    spi_data;
   logic                    spi_valid;

   logic [pwm_width-1:0]    pwm_thres;
   logic [pwm_bits-1:0]     pwm_sel;

   logic [pwm_width-1:0]    counter;
   logic                    overflow;


assign pwm_sel = spi_data[spi_width-1:pwm_width];
assign pwm_thres = spi_data[pwm_width-1:0];

spi_slave #(.width(spi_width)) spi(.*, .data_ready(spi_valid), .shiftreg(spi_data), .reset(0));
counter #(.counter_width(pwm_width)) counter_i(.*);
pwm #(.pwm_width(pwm_width)) pwm0(.*, .new_thres(pwm_thres), .set_thres(spi_valid), .pwm_out(pwm_out[0]));

assign pwm_out[0] = spi_data[spi_width-1];

endmodule
