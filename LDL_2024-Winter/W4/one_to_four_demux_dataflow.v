//This is for the 1:4 demux module.

module one_to_four_demux_dataflow_module (a, s0, s1, out1, out2, out3, out4);
	input a;
	input s0, s1;	
	output out1, out2, out3, out4;

	assign out1 = !s1 && !s0 && a;
	assign out2 = !s1 && s0 && a;
	assign out3 = s1 && !s0 && a;
	assign out4 = s1 && s0 && a;
	
endmodule
