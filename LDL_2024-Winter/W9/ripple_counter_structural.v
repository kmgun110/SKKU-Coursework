//This is for the ripple counter structural module.

module ripple_counter2_module(clk, rst, out);

  input clk;
	input rst;
	
  output [3:0] out;	
	wire [3:0] out_bar;
	
	jk_flip_flop_behavioral_module jk_ff_0 (.j(out_bar[0]), .k(out[0]), .clk(clk), .rst(rst), .q(out[0]), .q_bar(out_bar[0]));
	jk_flip_flop_behavioral_module jk_ff_1 (.j(out_bar[1]), .k(out[1]), .clk(out_bar[0]), .rst(rst), .q(out[1]), .q_bar(out_bar[1]));
	jk_flip_flop_behavioral_module jk_ff_2 (.j(out_bar[2]), .k(out[2]), .clk(out_bar[1]), .rst(rst), .q(out[2]), .q_bar(out_bar[2]));
	jk_flip_flop_behavioral_module jk_ff_3 (.j(out_bar[3]), .k(out[3]), .clk(out_bar[2]), .rst(rst), .q(out[3]), .q_bar(out_bar[3]));


endmodule