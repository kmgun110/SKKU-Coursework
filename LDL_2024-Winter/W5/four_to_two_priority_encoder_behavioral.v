//This is for the 4:2 priority encoder module.

module four_to_two_priority_encoder_behavioral_module (a, b, c, d, out0, out1);
	input a, b, c, d;

	output out0, out1;
	reg out0, out1;
	
	always@(a or b or c or d)
	begin
	  casex({d, c, b, a})
	   4'b 0000 : begin out1<=1'bx; out0<=1'bx; end
	   4'b 0001 : begin out1<=1'b0; out0<=1'b0; end
	   4'b 001x : begin out1<=1'b0; out0<=1'b1; end
	   4'b 01xx : begin out1<=1'b1; out0<=1'b0; end
	   4'b 1xxx : begin out1<=1'b1; out0<=1'b1; end
	  endcase
  end

endmodule
