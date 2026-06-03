//This is for the ring counter structural module.

module ring_counter_structural_module(clk, rst, preset, out);
  
  input clk;
  input rst;
  input [3:0] preset;
  
  output [3:0] out;
  wire [3:0] out_bar;
  
  d_flip_flop_behavioral_module d_ff_0(.d(out[3]), .clk(clk), .rst(rst), .preset(preset[0]), .q(out[0]), .q_bar(out_bar[0]));
  d_flip_flop_behavioral_module d_ff_1(.d(out[0]), .clk(clk), .rst(rst), .preset(preset[1]), .q(out[1]), .q_bar(out_bar[1]));
  d_flip_flop_behavioral_module d_ff_2(.d(out[1]), .clk(clk), .rst(rst), .preset(preset[2]), .q(out[2]), .q_bar(out_bar[2]));
  d_flip_flop_behavioral_module d_ff_3(.d(out[2]), .clk(clk), .rst(rst), .preset(preset[3]), .q(out[3]), .q_bar(out_bar[3]));
  
endmodule