module por
  (
   por,
   clk
   );

parameter cycles = 2;

   output logic por;
   input wire   clk;

   logic [cycles-1:0] por_b = { default:'0 };

always_ff @(posedge clk)
  por_b[0] <= 1'b1;

for (genvar i = 0; i < cycles - 1; ++i)
  always_ff @(posedge clk)
    por_b[i + 1] <= por_b[i];

assign por = por_b[cycles-1];

endmodule
