module mux
  (
   clk,
   rst,

   write_addr,
   write_data,
   write_enable,
   write_done,

   read_addr,
   read_data,
   read_latch
   );
parameter width = 16;
parameter num_reg = 3;

localparam addr_width = $clog2(num_reg);
   typedef logic [width-1:0] elem_t;
   typedef logic [addr_width-1:0] addr_t;

   input var logic clk;
   input var logic rst;

   input addr_t    write_addr;
   input elem_t    write_data;
   input var logic write_enable;
   input var logic write_done;

   input addr_t    read_addr;
   output elem_t   read_data;
   input var logic read_latch;


   logic           need_swap;

always @(posedge clk or posedge rst)
  if (rst) begin
     need_swap <= 0;
  end else begin
     if (write_done)
       need_swap <= 1;
     else if (read_latch)
       need_swap <= 0;
  end


   logic read_buf;
   logic write_buf;

assign write_buf = ~read_buf;

always @(posedge clk or posedge rst)
  if (rst) begin
     read_buf <= 0;
  end else begin
     if (read_latch && need_swap)
       read_buf <= ~read_buf;
  end


elem_t [1:0] data_out;

for (genvar blkid = 0; blkid < 2; ++blkid) begin: muxmem
   logic mem_write_enable;
   addr_t mem_addr;

   assign mem_write_enable = (write_buf == blkid) && write_enable;
   assign mem_addr = ((read_buf == blkid) || ~mem_write_enable) ? read_addr : write_addr;

   mem #(.width(width), .entries(num_reg))
   mem(.write_enable(mem_write_enable),
       .addr(mem_addr),
       .data_in(write_data),
       .data_out(data_out[blkid]),
       .*);
end

assign read_data = data_out[read_buf];

endmodule
