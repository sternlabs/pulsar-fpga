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
   logic [pwm_width-1:0]          rdata_int[0:1];

assign write_slice = ~read_slice;

always_ff @(posedge clk or posedge rst)
  if (rst)
    read_slice <= 0;
  else
    if (latch_mem)
      read_slice <= ~read_slice;

   logic                          we0, we1;

assign we0 = write_enable & (write_slice == 0);
assign we1 = write_enable & (write_slice == 1);

   logic [$clog2(num_pwm)-1:0]    addr[0:1];

assign addr[0] = we0 ? waddr : raddr;
assign addr[1] = we1 ? waddr : raddr;

always_ff @(posedge clk)
  if (we0)
    mem[addr[0]][0]  = wdata;
assign rdata_int[0] = (read_slice == 0) ? mem[addr[0]][0] : {default:'z};

always_ff @(posedge clk)
  if (we1)
    mem[addr[1]][1] = wdata;
assign rdata_int[1] = (read_slice == 1) ? mem[addr[1]][1] : {default:'z};

assign rdata = read_slice == 0 ? rdata_int[0] : rdata_int[1];

endmodule
