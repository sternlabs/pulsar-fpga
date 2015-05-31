module mem
  (
   clk,
   rst,

   write_enable,
   addr,
   data_in,
   data_out
   );

parameter width = 12;
parameter entries = 6;

localparam addr_width = $clog2(entries);
   typedef logic[width-1:0] elem_t;

   input var logic          clk;
   input var logic          rst;

   input var logic          write_enable;
   input var logic [addr_width-1:0] addr;
   input elem_t             data_in;
   output elem_t            data_out;


   logic [addr_width-1:0]   addr_out;
   elem_t                   mem[0:entries-1];

always @(posedge clk or posedge rst)
  if (rst) begin
     for (int i = 0; i < entries; ++i)
       mem[i] = 0;
  end else begin
     if (write_enable)
       mem[addr]  = data_in;
     addr_out     = addr;
  end

assign data_out = mem[addr_out];

endmodule
