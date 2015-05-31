module top
  (
   nCS,
   SCK,
   MOSI,

   pwm_out
   );
parameter pwm_width = 16;
parameter num_pwm = 12;

function integer roundup8;
   input integer            bits;
   begin
      return (bits + 7) / 8 * 8;
   end
endfunction

localparam spi_data_bits = roundup8(pwm_width);
localparam spi_width = spi_data_bits;


   input wire                 nCS;
   input wire                 SCK;
   input wire                 MOSI;

   output logic [num_pwm-1:0] pwm_out;

   logic                      clk;
   logic                      rst;

   logic [spi_width-1:0]      spi_data;
   logic                      new_transfer;
   logic                      transfer_done;
   logic                      data_ready;

   logic [$clog2(num_pwm)-1:0] write_addr;
   logic [num_pwm-1:0]         write_data;
   logic                       write_enable;
   logic                       write_done;

   logic [$clog2(num_pwm)-1:0] read_addr;
   logic [num_pwm-1:0]         read_data;
   logic                       read_latch;


platform platform(.*);

spi_slave #(.width(spi_width))
spi(.reset(rst),
    .shiftreg(spi_data),
    .*);

regwrite #(.width(num_pwm),
           .num_reg(pwm_width))
regwrite_i(.data_in(spi_data[num_pwm-1:0]),
           .*);

mux #(.width(num_pwm),
      .num_reg(pwm_width))
mux_i(.*);

pwm #(.pwm_width(pwm_width),
      .num_pwm(num_pwm))
pwm_i(.pwm_addr(read_addr),
      .pwm_data(read_data),
      .latch_mem(read_latch),
      .*);

endmodule
