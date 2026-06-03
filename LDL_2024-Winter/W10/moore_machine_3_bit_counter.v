//Moore machine

module moore_machine_3_bit_counter_module(clk, mode, rst, out, state, next_state);
	input clk, mode, rst;
	
	output [2:0] out, state, next_state;
	reg	[2:0] out, state, next_state;
 
	//States
	parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6, S7 = 7;
		
	//Determine the output depending on the current state only 
	always @ (state) begin
		case (state)
			S0:	out = S0;
			S1:	out = S1;
			S2:	out = S2;
			S3:	out = S3;
			S4:	out = S4;
			S5:	out = S5;
			S6:	out = S6;
			S7:	out = S7;
			default: out = S0;
		endcase
	end
	
	//Update the current state
	always @ (posedge clk) 
	begin
		if (rst == 1'b1)
			state = S0;
		else
			state = next_state;
	end

	//Determine the next state
always @ (posedge clk) 
	begin
		if (rst == 1'b1)
			next_state <= S0;
		else
		begin
			case (state)
				S0: 
				begin
					if (mode == 1'b1)
						next_state <= S1;
					else
						next_state <= S7;
				end
				S1:
				begin
					if (mode == 1'b1)
						next_state <= S2;
					else
						next_state <= S0;
				end
				S2:
				begin
					if (mode == 1'b1)
						next_state <= S3;
					else
						next_state <= S1;
				end
				S3:
				begin
					if (mode == 1'b1)
						next_state <= S4;
					else
						next_state <= S2;
				end
				S4: 
				begin
					if (mode == 1'b1)
						next_state <= S5;
					else
						next_state <= S3;
				end
				S5:
				begin
					if (mode == 1'b1)
						next_state <= S6;
					else
						next_state <= S4;
				end
				S6:
				begin
					if (mode == 1'b1)
						next_state <= S7;
					else
						next_state <= S5;
				end
				S7:
				begin
					if (mode == 1'b1)
						next_state <= S0;
					else
						next_state <= S6;
				end
			endcase
		end
	end
	
endmodule
