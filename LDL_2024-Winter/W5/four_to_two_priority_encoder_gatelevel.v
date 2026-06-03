//This is for the 4:2 priority encoder module.

module four_to_two_priority_encoder_gatelevel_module (a, b, c, d, out0, out1);
	input a, b, c, d;

	output out0, out1;
	
	wire not_1_output, and_1_output;
	
  not_gate not_1 (.a(c), .out(not_1_output));
  and_gate and_1 (.a(b), .b(not_1_output), .out(and_1_output));
  or_gate or_1 (.a(d), .b(and_1_output), .out(out0));
  
  or_gate or_2 (.a(c), .b(d), .out(out1));   

endmodule
