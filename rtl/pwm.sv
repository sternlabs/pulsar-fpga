module pwm
  #(parameter pwm_width = 16,
    parameter num_pwm = 4
)
(
 input wire                       clk,
 input wire [pwm_width-1:0]       new_thres,
 input wire [$clog2(num_pwm)-1:0] sel_thres,
 input wire                       set_thres,
 output logic [num_pwm-1:0]       pwm_out
 );


   logic [num_pwm-1:0]      pwm_sel_onehot;

   logic [pwm_width-1:0]    counter;
   logic                    overflow;

   genvar                   pwm_id;


assign pwm_sel_onehot = 1 << sel_thres;


counter #(.counter_width(pwm_width)) counter_i(.*);

for (pwm_id = 0; pwm_id < num_pwm; ++pwm_id)
begin

   logic [pwm_width-1:0]    thres;
   logic                    pwm_match;

   // manually calculate comparison to avoid the default comparator
   // implementation, which uses carry chains and overflows our fpga.
   assign pwm_match = ~ |(counter ^ thres);

   always_ff @(posedge clk)
     if (overflow & set_thres & pwm_sel_onehot[pwm_id])
       thres <= new_thres;

always_ff @(posedge clk)
begin
   if (overflow)
     pwm_out[pwm_id] <= 1;
   if (pwm_match)
     pwm_out[pwm_id] <= 0;
end

end

endmodule
