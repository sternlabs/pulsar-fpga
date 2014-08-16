module pwm
#(parameter pwm_width = 16)
(
 input wire                 clk,
 input wire [pwm_width-1:0] counter,
 input wire                 overflow,
 input wire [pwm_width-1:0] new_thres,
 input wire                 set_thres,
 output logic               pwm_out
 );

   logic [pwm_width-1:0]    thres;
   logic                    pwm_match;


assign pwm_match = counter == thres;

always_ff @(posedge clk)
  if (overflow & set_thres)
    thres <= new_thres;

always_ff @(posedge clk)
begin
   if (overflow)
     pwm_out <= 1;
   if (pwm_match)
     pwm_out <= 0;
end

endmodule
