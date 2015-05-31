`default_nettype none
`timescale 1 ns / 100 ps

  module spi_slave
    #(parameter width = 24)
(
 input wire               nCS,
 input wire               SCK,
 input wire               MOSI,

 input wire               clk,
 input wire               reset,
 output logic [width-1:0] shiftreg,
 output logic             new_transfer,
 output logic             transfer_done,
 output logic             data_ready
 );


   logic [2:0]            nCS_s;
   logic                  nCS_rising, nCS_falling;
always_ff @(posedge clk) nCS_s <= {nCS_s[1:0], nCS};
assign nCS_rising = (nCS_s[2:1] == 2'b01);
assign nCS_falling = (nCS_s[2:1] == 2'b10);

   logic                  chip_selected;
assign chip_selected = ~nCS_s[1];

   logic [2:0]            SCK_s;
   logic                  SCK_rising;
always_ff @(posedge clk) SCK_s <= {SCK_s[1:0], SCK};
assign SCK_rising = (SCK_s[2:1] == 2'b01);

   logic [1:0]            MOSI_s;
always_ff @(posedge clk) MOSI_s <= {MOSI_s[0], MOSI};
   logic                  MOSI_sync;
assign MOSI_sync = MOSI_s[1];

   logic [$clog2(width)-1:0] numbits;
   logic                   is_last_bit;
assign is_last_bit = numbits == width - 1;

always_ff @(posedge clk)
begin
   if (~chip_selected) begin
      numbits <= 0;
   end else if (SCK_rising) begin
      numbits  <= numbits + 1;
      if (is_last_bit)
        numbits <= 0;
      shiftreg <= {shiftreg[width-2:0], MOSI_sync};
   end
end

always_ff @(posedge clk)
  data_ready <= chip_selected && SCK_rising && is_last_bit;

always_ff @(posedge clk)
  new_transfer <= nCS_falling;

always_ff @(posedge clk)
  transfer_done <= nCS_rising;

endmodule
