module platform
  (
   output logic clk,
   output logic rst
   );


defparam OSCH_inst.NOM_FREQ = "53.2";
OSCH OSCH_inst(.STDBY(1'b0),
               .OSC(clk),
               .SEDSTDBY());


   logic        rst_n;

defparam por_i.cycles = 1;
por por_i(.por(rst_n),
          .clk(clk));

assign rst = ~rst_n;

GSR GSR_INST(.GSR(rst_n));
PUR PUR_INST(.PUR(rst_n));

endmodule
