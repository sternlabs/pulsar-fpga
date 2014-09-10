module thresmem
  #(
    parameter pwm_width = 16,
    parameter num_pwm = 4
    )
(
 input wire                       clk,
 input wire                       rst,

 input wire                       write_enable,
 input wire [$clog2(num_pwm)-1:0]  waddr,
 input wire [pwm_width-1:0]       wdata,

 input wire                       latch_mem,
 input wire [$clog2(num_pwm)-1:0] raddr,
 output logic [pwm_width-1:0]     rdata
 );

   logic [pwm_width-1:0]          mem[0:num_pwm-1][0:1];
   logic                          read_slice, write_slice;

assign write_slice = ~read_slice;

always_ff @(posedge clk or posedge rst)
  if (rst)
    read_slice <= 0;
  else
    if (latch_mem)
      read_slice <= ~read_slice;

always_ff @(posedge clk)
  if (write_enable & write_slice == 0)
    mem[waddr][0] <= wdata;

always_ff @(posedge clk)
  if (write_enable & write_slice == 1)
    mem[waddr][1] <= wdata;

assign rdata = read_slice == 0 ? mem[raddr][0] : mem[raddr][1];

endmodule
