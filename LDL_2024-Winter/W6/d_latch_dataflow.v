//This is for the D latch module.

module d_latch_dataflow_module (d, en, q, q_bar);
	input d;
	input en; //enable

	output q, q_bar;
	
	assign q = !((en && !d) || q_bar);
	assign q_bar = !((en && d) || q);
	
endmodule

