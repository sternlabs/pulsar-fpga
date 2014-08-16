module counter
#(parameter counter_width = 16)
(
 input wire                       clk,
 output logic [counter_width-1:0] counter,
 output logic                     overflow
 );

   logic [counter_width-1:0]      counter_nxt;
   logic                          overflow, overflow_nxt;

assign counter_nxt = counter + 1;
assign overflow_nxt = (counter[counter_width-1] == 1'b1) &
                      (counter_nxt[counter_width-1] == 1'b0);

always_ff @(posedge clk)
begin 
   counter  <= counter_nxt;
   overflow <= overflow_nxt;
end

endmodule
