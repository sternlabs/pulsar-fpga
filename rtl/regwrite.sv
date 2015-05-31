module regwrite
  #(
    parameter width = 16,
    parameter num_reg = 4
    )
(
 clk,
 rst,

 data_in,
 data_ready,
 new_transfer,
 transfer_done,

 write_addr,
 write_data,
 write_enable,
 write_done
 );

localparam addr_width = $clog2(num_reg);

   input var logic clk;
   input var logic rst;

   input var logic [width-1:0] data_in;
   input var logic             data_ready;
   input var logic             new_transfer;
   input var logic             transfer_done;

   output logic [addr_width-1:0] write_addr;
   output logic [width-1:0]      write_data;
   output logic                  write_enable;
   output logic                  write_done;


assign write_enable = data_ready;
assign write_done = transfer_done;
assign write_data = data_in;

always @(posedge clk)
  if (new_transfer)
    write_addr <= 0;
  else if (data_ready) begin
     write_addr     <= write_addr + 1;
     if (write_addr == num_reg - 1)
       write_addr <= 0;
  end

endmodule
