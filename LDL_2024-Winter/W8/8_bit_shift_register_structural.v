//This is a 8-bit shift register module.

module eight_bit_shift_register_structural_module(shift_in, clk, rst, out);

	input shift_in;
	input clk; 
	input rst; 
	output [7:0] out;

  one_bit_register_behavioral_module obr_0 (.in(shift_in), .clk(clk), .rst(rst), .out(out[0]));
	one_bit_register_behavioral_module obr_1 (.in(out[0]), .clk(clk), .rst(rst), .out(out[1]));	
	one_bit_register_behavioral_module obr_2 (.in(out[1]), .clk(clk), .rst(rst), .out(out[2]));
	one_bit_register_behavioral_module obr_3 (.in(out[2]), .clk(clk), .rst(rst), .out(out[3]));
	one_bit_register_behavioral_module obr_4 (.in(out[3]), .clk(clk), .rst(rst), .out(out[4]));
	one_bit_register_behavioral_module obr_5 (.in(out[4]), .clk(clk), .rst(rst), .out(out[5]));
	one_bit_register_behavioral_module obr_6 (.in(out[5]), .clk(clk), .rst(rst), .out(out[6]));
	one_bit_register_behavioral_module obr_7 (.in(out[6]), .clk(clk), .rst(rst), .out(out[7]));

endmodule

