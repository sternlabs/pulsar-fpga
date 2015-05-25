module pwm
  #(
    parameter pwm_width = 16,
    parameter num_pwm = 4
    )
(
 clk,
 rst,
 pwm_addr,
 pwm_data,
 latch_mem,
 pwm_out
 );

   typedef logic  [$clog2(pwm_width)-1:0] pwm_addr_t;

   input var logic                        clk;
   input var logic                        rst;
   output                                 pwm_addr_t pwm_addr;
   input var logic [num_pwm-1:0]          pwm_data;
   output logic                           latch_mem;

   output logic [num_pwm-1:0]             pwm_out;

pwm_addr_t pwm_addr_nxt;
   logic [pwm_width-1:0]                  counter, counter_plus_one, counter_nxt;
   logic                                  overflow, overflow_nxt;


assign latch_mem = overflow;

assign counter_plus_one = counter + 1;
assign overflow_nxt = (counter[pwm_width-1] == 1'b1) &
                      (counter_plus_one[pwm_width-1] == 1'b0);
assign counter_nxt = overflow_nxt ? 1 : counter_plus_one;

always_ff @(posedge clk or posedge rst)
  if (rst)
  begin
     counter  <= 1;
     overflow <= 0;
  end else begin
     counter  <= counter_nxt;
     overflow <= overflow_nxt;
  end

always_comb
begin
   pwm_addr_nxt  = 0;

   for (int i = 0; i < pwm_width; ++i)
     if (counter[i])
       pwm_addr_nxt  = i;
end

assign pwm_addr = pwm_addr_nxt;
// always_ff @(posedge clk or posedge rst)
//   if (rst)
//     pwm_addr <= 0;
//   else
//     pwm_addr <= pwm_addr_nxt;


assign pwm_out = pwm_data;

endmodule
