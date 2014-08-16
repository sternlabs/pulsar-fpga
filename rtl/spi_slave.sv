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
  output logic             data_ready
);


   logic [$clog2(width):0] numbits, numbits_nxt;
   logic                   is_last_bit;

   logic                   sck_data_ready, sck_data_ready_nxt;
   logic                   clk_data_ready[1:0];

   logic [width-1:0]       shiftreg, shiftreg_nxt;


assign numbits_nxt = numbits + 1'd1;
assign is_last_bit = numbits == width - 1;

assign sck_data_ready_nxt = sck_data_ready ? 1 : is_last_bit;

assign shiftreg_nxt = sck_data_ready ? shiftreg : {shiftreg[width-2:0],MOSI};


always_ff @(posedge SCK or posedge nCS)
  if (nCS) begin
     shiftreg       <= 0;
     numbits        <= 0;
     sck_data_ready <= 0;
  end else begin // if (~nCS)
     shiftreg       <= shiftreg_nxt;
     numbits        <= numbits_nxt;
     sck_data_ready <= sck_data_ready_nxt;
  end


always_ff @(posedge clk or posedge reset)
  if (reset) begin
     clk_data_ready <= 0;
  end else begin
     clk_data_ready <= {clk_data_ready[0],sck_data_ready};
  end

assign data_ready = clk_data_ready[1];

endmodule
