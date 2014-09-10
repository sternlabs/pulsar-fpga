module pwm
  #(
    parameter pwm_width = 16,
    parameter num_pwm = 4
    )
(
 input wire                         clk,
 input wire                         rst,
 output logic [$clog2(num_pwm)-1:0] thres_id,
 input wire [pwm_width-1:0]         thres,
 output logic                       latch_mem,
 output logic [num_pwm-1:0]         pwm_out
 );


   logic                    pwm_match;
   logic                    match_result;
   logic                    pwm_event;
   logic [num_pwm-1:0]      pwm_out_nxt;

   logic [pwm_width-1:0]    counter, counter_nxt;
   logic                    overflow, overflow_nxt;

   logic [$clog2(num_pwm)-1:0] pwm_round, pwm_round_nxt;
   logic                       new_round;


assign latch_mem = overflow_nxt & new_round;

assign pwm_round_nxt = (pwm_round == num_pwm - 1) ? 0 : pwm_round + 1;
assign new_round = pwm_round_nxt == 0;
assign thres_id = pwm_round_nxt;

always_ff @(posedge clk or posedge rst)
  if (rst)
    pwm_round <= 0;
  else
    pwm_round <= pwm_round_nxt;


assign counter_nxt = &(counter + 1'b1) ? 0 : counter + 1;
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
assign pwm_match = ~(|(counter ^ thres));

always_comb
begin
   pwm_event  = 0;
   match_result = 0;
   if (overflow)
   begin
      match_result  = 1;
      pwm_event     = 1;
   end
   if (pwm_match)
   begin
      match_result  = 0;
      pwm_event     = 1;
   end
end

always_ff @(posedge clk or posedge rst)
  if (rst)
    pwm_out_nxt <= { default:'0 };
  else
    if (pwm_event)
      pwm_out_nxt[pwm_round] <= match_result;


// synchronize all pwm channels;
// short circuit last channel output
always_ff @(posedge clk or posedge rst)
  if (rst)
    pwm_out <= { default:'0 };
  else
    if (new_round)
      pwm_out <= {pwm_event ? match_result : pwm_out_nxt[num_pwm-1], pwm_out_nxt[num_pwm-2:0]};


endmodule
