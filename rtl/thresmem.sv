module thresmem
(
 clk,
 rst,

 write_enable,
 waddr,
 wdata,

 latch_mem,
 raddr,
 rdata
 );

parameter pwm_width = 16;
parameter num_pwm = 4;

localparam elem_count = pwm_width;
localparam addr_width = $clog2(elem_count);
localparam mem_width = num_pwm;

   typedef logic [addr_width-1:0] addr_t;
   typedef logic [mem_width-1:0]  elem_t;

   input var logic                clk;
   input var logic                rst;

   input var logic                write_enable;
   input                          addr_t waddr;
   input                          elem_t wdata;

   input var logic                latch_mem;
   input                          addr_t raddr;
   output                         elem_t     rdata;

elem_t         mem[0:elem_count-1][0:1];
   logic                          read_slice, write_slice;
addr_t         rdata_int[0:1];

   logic                          had_change;


assign write_slice = ~read_slice;

always_ff @(posedge clk or posedge rst)
  if (rst)
    read_slice <= 0;
  else
    if (latch_mem & had_change)
      read_slice <= ~read_slice;

always_ff @(posedge clk or posedge rst)
  if (rst)
    had_change <= 0;
  else
    if (latch_mem)
      had_change <= 0;
    else
      had_change <= had_change | write_enable;



   logic                          we0, we1;

assign we0 = write_enable & (write_slice == 0);
assign we1 = write_enable & (write_slice == 1);

addr_t   addr[0:1];

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
