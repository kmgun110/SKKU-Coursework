
module d_flip_flop_module (d, clk, rst, q, q_bar);
	input d;
	input clk; // clock
	input rst;

	output q, q_bar;
	reg q, q_bar;	
	
	always@(posedge clk or posedge rst)
	begin
		if(rst == 1'b1)
		begin
		   q <= 1'b0;
	       q_bar <= 1'b1;
		end
		else
		begin
			q <= d;
			q_bar <= !d;		
		end
	end
endmodule
