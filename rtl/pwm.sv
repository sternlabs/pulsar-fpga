module pwm
  #(parameter pwm_width = 16,
    parameter num_pwm = 4
    )
(
 input wire                 clk,
 input wire                 rst,
 input wire [pwm_width-1:0] thres [num_pwm-1:0],
 output logic [num_pwm-1:0] pwm_out
 );


   logic [pwm_width-1:0]    pwm_thres [num_pwm-1:0];
   logic [pwm_width-1:0]    cur_thres;

   logic                    pwm_match;
   logic                    match_result;
   logic                    pwm_event;
   logic [num_pwm-1:0]      pwm_out_nxt;

   logic [pwm_width-1:0]    counter, counter_nxt;
   logic                    overflow, overflow_nxt;

   logic [$clog2(num_pwm)-1:0] pwm_round, pwm_round_nxt;
   logic                       new_round;
   logic                       latch_mem;


// single port memory
// short-circuit channel 0 from input thresholds
assign latch_mem = overflow_nxt & new_round;

always_ff @(posedge clk or posedge rst)
  if (rst)
  begin
     pwm_thres <= { default:'0 };
     cur_thres <= 0;
  end else begin
     if (latch_mem)
     begin
        pwm_thres <= thres;
        cur_thres <= thres[0];
     end else begin
        cur_thres <= thres[pwm_round];
     end
  end


assign pwm_round_nxt = (pwm_round == num_pwm - 1) ? 0 : pwm_round + 1;
assign new_round = pwm_round_nxt == 0;

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
assign pwm_match = ~(|(counter ^ cur_thres));

always_comb
begin
   pwm_event = 0;
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
