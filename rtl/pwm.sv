module pwm
  #(parameter pwm_width = 16,
    parameter num_pwm = 4
)
(
 input wire                       clk,
 input wire                       rst,
 input wire [pwm_width-1:0]       new_thres,
 input wire [$clog2(num_pwm)-1:0] sel_thres,
 input wire                       set_thres,
 output logic [num_pwm-1:0]       pwm_out
 );


   logic [pwm_width-1:0]          counter, counter_nxt;
   logic                          overflow, overflow_nxt;

   logic [pwm_width-1:0]          thres [num_pwm] = {0}, cur_thres;

   logic [$clog2(num_pwm)-1:0]    pwm_round = 0, pwm_round_nxt;
   logic                          new_round;

   logic                          pwm_match;


assign pwm_round_nxt = pwm_round + 1;
assign new_round = pwm_round == num_pwm-1;

always_ff @(posedge clk or posedge rst)
  if (rst)
  begin
     cur_thres <= 0;
     pwm_round <= 0;
  end else begin
     cur_thres <= thres[pwm_round_nxt];
     pwm_round <= pwm_round_nxt;
  end


assign counter_nxt = counter + 1;
assign overflow_nxt = (counter[pwm_width-1] == 1'b1) &
                      (counter_nxt[pwm_width-1] == 1'b0);

always_ff @(posedge clk or posedge rst)
  if (rst)
  begin
     counter  <= 0;
     overflow <= 0;
  end else
    if (new_round)
    begin
       counter  <= counter_nxt;
       overflow <= overflow_nxt;
    end


// manually calculate comparison to avoid the default comparator
// implementation, which uses carry chains and overflows our fpga.
assign pwm_match = ~(|(counter ^ cur_thres));

always_ff @(posedge clk or posedge rst)
  if (rst)
    pwm_out <= '{0};
  else begin
     if (overflow)
       pwm_out[pwm_round] <= 1;
     if (pwm_match)
       pwm_out[pwm_round] <= 0;
  end


always_ff @(posedge clk)
  if (overflow & set_thres)
    thres[sel_thres] <= new_thres;

endmodule
