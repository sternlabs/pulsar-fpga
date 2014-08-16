module top
  #(
    parameter pwm_width = 8,
    parameter num_pwm = 12
    )
(
 input wire                 nCS,
 input wire                 SCK,
 input wire                 MOSI,

 input wire                 clk,

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

   logic [pwm_width-1:0]    pwm_thres;
   logic [pwm_bits-1:0]     pwm_sel_bin;
   logic [num_pwm-1:0]      pwm_sel_onehot;

   logic [pwm_width-1:0]    counter;
   logic                    overflow;

   genvar                   pwm_id;


assign pwm_sel_bin = spi_data[spi_width-1:spi_width-spi_data_bits];
assign pwm_sel_onehot = 1 << pwm_sel_bin;
assign pwm_thres = spi_data[pwm_width-1:0];

spi_slave #(.width(spi_width)) spi(.*, .data_ready(spi_valid), .shiftreg(spi_data), .reset(0));
counter #(.counter_width(pwm_width)) counter_i(.*);


for (pwm_id = 0; pwm_id < num_pwm; ++pwm_id)
begin
  pwm #(.pwm_width(pwm_width)) pwm(.*, .new_thres(pwm_thres), .set_thres(pwm_sel_onehot[pwm_id]), .pwm_out(pwm_out[pwm_id]));
end

endmodule
