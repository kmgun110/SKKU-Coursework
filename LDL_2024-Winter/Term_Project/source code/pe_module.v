module pe_module(a, b, clk, rst, out, out_a, out_b);
	input [7:0] a, b;
	input clk;
	input rst;

	output [7:0] out, out_a, out_b;

	wire [35:0] and_out;
	wire [35:0] fa_out;
	wire [35:0] cout;

	wire [23:0] q_bar;	
	

	//multiplier
	and_gate and_1(.a(a[0]), .b(b[0]), .out(and_out[0]));
	and_gate and_2(.a(a[1]), .b(b[0]), .out(and_out[1]));
	and_gate and_3(.a(a[2]), .b(b[0]), .out(and_out[2]));
	and_gate and_4(.a(a[3]), .b(b[0]), .out(and_out[3]));
	and_gate and_5(.a(a[4]), .b(b[0]), .out(and_out[4]));
	and_gate and_6(.a(a[5]), .b(b[0]), .out(and_out[5]));
	and_gate and_7(.a(a[6]), .b(b[0]), .out(and_out[6]));
	and_gate and_8(.a(a[7]), .b(b[0]), .out(and_out[7]));

	and_gate and_9(.a(a[0]), .b(b[1]), .out(and_out[8]));
	and_gate and_10(.a(a[1]), .b(b[1]), .out(and_out[9]));
	and_gate and_11(.a(a[2]), .b(b[1]), .out(and_out[10]));
	and_gate and_12(.a(a[3]), .b(b[1]), .out(and_out[11]));
	and_gate and_13(.a(a[4]), .b(b[1]), .out(and_out[12]));
	and_gate and_14(.a(a[5]), .b(b[1]), .out(and_out[13]));
	and_gate and_15(.a(a[6]), .b(b[1]), .out(and_out[14]));

	and_gate and_16(.a(a[0]), .b(b[2]), .out(and_out[15]));
	and_gate and_17(.a(a[1]), .b(b[2]), .out(and_out[16]));
	and_gate and_18(.a(a[2]), .b(b[2]), .out(and_out[17]));
	and_gate and_19(.a(a[3]), .b(b[2]), .out(and_out[18]));
	and_gate and_20(.a(a[4]), .b(b[2]), .out(and_out[19]));
	and_gate and_21(.a(a[5]), .b(b[2]), .out(and_out[20]));

	and_gate and_22(.a(a[0]), .b(b[3]), .out(and_out[21]));
	and_gate and_23(.a(a[1]), .b(b[3]), .out(and_out[22]));
	and_gate and_24(.a(a[2]), .b(b[3]), .out(and_out[23]));
	and_gate and_25(.a(a[3]), .b(b[3]), .out(and_out[24]));
	and_gate and_26(.a(a[4]), .b(b[3]), .out(and_out[25]));

	and_gate and_27(.a(a[0]), .b(b[4]), .out(and_out[26]));
	and_gate and_28(.a(a[1]), .b(b[4]), .out(and_out[27]));
	and_gate and_29(.a(a[2]), .b(b[4]), .out(and_out[28]));
	and_gate and_30(.a(a[3]), .b(b[4]), .out(and_out[29]));

	and_gate and_31(.a(a[0]), .b(b[5]), .out(and_out[30]));
	and_gate and_32(.a(a[1]), .b(b[5]), .out(and_out[31]));
	and_gate and_33(.a(a[2]), .b(b[5]), .out(and_out[32]));

	and_gate and_34(.a(a[0]), .b(b[6]), .out(and_out[33]));
	and_gate and_35(.a(a[1]), .b(b[6]), .out(and_out[34]));

	and_gate and_36(.a(a[0]), .b(b[7]), .out(and_out[35]));

	// and_out[0] = out[0]
	// calculate out[1]
	full_adder_module fa_1(.a(and_out[1]), .b(and_out[8]), .cin(1'b0), .sum(fa_out[0]), .cout(cout[0])); //fa_out[0] = out[1]
	full_adder_module fa_2(.a(and_out[2]), .b(and_out[9]), .cin(cout[0]), .sum(fa_out[1]), .cout(cout[1]));
	full_adder_module fa_3(.a(and_out[3]), .b(and_out[10]), .cin(cout[1]), .sum(fa_out[2]), .cout(cout[2]));
	full_adder_module fa_4(.a(and_out[4]), .b(and_out[11]), .cin(cout[2]), .sum(fa_out[3]), .cout(cout[3]));
	full_adder_module fa_5(.a(and_out[5]), .b(and_out[12]), .cin(cout[3]), .sum(fa_out[4]), .cout(cout[4]));
	full_adder_module fa_6(.a(and_out[6]), .b(and_out[13]), .cin(cout[4]), .sum(fa_out[5]), .cout(cout[5]));
	full_adder_module fa_7(.a(and_out[7]), .b(and_out[14]), .cin(cout[5]), .sum(fa_out[6]), .cout(cout[6]));

	// calculate out[2]
	full_adder_module fa_8(.a(fa_out[1]), .b(and_out[15]), .cin(1'b0), .sum(fa_out[7]), .cout(cout[7])); //fa_out[7] = out[2]
	full_adder_module fa_9(.a(fa_out[2]), .b(and_out[16]), .cin(cout[7]), .sum(fa_out[8]), .cout(cout[8]));
	full_adder_module fa_10(.a(fa_out[3]), .b(and_out[17]), .cin(cout[8]), .sum(fa_out[9]), .cout(cout[9]));
	full_adder_module fa_11(.a(fa_out[4]), .b(and_out[18]), .cin(cout[9]), .sum(fa_out[10]), .cout(cout[10]));
	full_adder_module fa_12(.a(fa_out[5]), .b(and_out[19]), .cin(cout[10]), .sum(fa_out[11]), .cout(cout[11]));
	full_adder_module fa_13(.a(fa_out[6]), .b(and_out[20]), .cin(cout[11]), .sum(fa_out[12]), .cout(cout[12]));

	// calculate out[3]
	full_adder_module fa_14(.a(fa_out[8]), .b(and_out[21]), .cin(1'b0), .sum(fa_out[13]), .cout(cout[13])); //fa_out[13] = out[3]
	full_adder_module fa_15(.a(fa_out[9]), .b(and_out[22]), .cin(cout[13]), .sum(fa_out[14]), .cout(cout[14]));
	full_adder_module fa_16(.a(fa_out[10]), .b(and_out[23]), .cin(cout[14]), .sum(fa_out[15]), .cout(cout[15]));
	full_adder_module fa_17(.a(fa_out[11]), .b(and_out[24]), .cin(cout[15]), .sum(fa_out[16]), .cout(cout[16]));
	full_adder_module fa_18(.a(fa_out[12]), .b(and_out[25]), .cin(cout[16]), .sum(fa_out[17]), .cout(cout[17]));

	// calculate out[4]
	full_adder_module fa_19(.a(fa_out[14]), .b(and_out[26]), .cin(1'b0), .sum(fa_out[18]), .cout(cout[18])); //fa_out[18] = out[4]
	full_adder_module fa_20(.a(fa_out[15]), .b(and_out[27]), .cin(cout[18]), .sum(fa_out[19]), .cout(cout[19]));
	full_adder_module fa_21(.a(fa_out[16]), .b(and_out[28]), .cin(cout[19]), .sum(fa_out[20]), .cout(cout[20]));
	full_adder_module fa_22(.a(fa_out[17]), .b(and_out[29]), .cin(cout[20]), .sum(fa_out[21]), .cout(cout[21]));

	// calculate out[5]
	full_adder_module fa_23(.a(fa_out[19]), .b(and_out[30]), .cin(1'b0), .sum(fa_out[22]), .cout(cout[22])); //fa_out[22] = out[5]
	full_adder_module fa_24(.a(fa_out[20]), .b(and_out[31]), .cin(cout[22]), .sum(fa_out[23]), .cout(cout[23]));
	full_adder_module fa_25(.a(fa_out[21]), .b(and_out[32]), .cin(cout[23]), .sum(fa_out[24]), .cout(cout[24]));

	// calculate out[6]
	full_adder_module fa_26(.a(fa_out[23]), .b(and_out[33]), .cin(1'b0), .sum(fa_out[25]), .cout(cout[25])); //fa_out[25] = out[6]
	full_adder_module fa_27(.a(fa_out[24]), .b(and_out[34]), .cin(cout[25]), .sum(fa_out[26]), .cout(cout[26]));

	// calculate out[7]
	full_adder_module fa_28(.a(fa_out[26]), .b(and_out[35]), .cin(1'b0), .sum(fa_out[27]), .cout(cout[27])); //fa_out[27] = out[7]
	

	// adder
	full_adder_module fa_29(.a(and_out[0]), .b(out[0]), .cin(1'b0), .sum(fa_out[28]), .cout(cout[28]));
	full_adder_module fa_30(.a(fa_out[0]), .b(out[1]), .cin(cout[28]), .sum(fa_out[29]), .cout(cout[29]));
	full_adder_module fa_31(.a(fa_out[7]), .b(out[2]), .cin(cout[29]), .sum(fa_out[30]), .cout(cout[30]));
	full_adder_module fa_32(.a(fa_out[13]), .b(out[3]), .cin(cout[30]), .sum(fa_out[31]), .cout(cout[31]));
	full_adder_module fa_33(.a(fa_out[18]), .b(out[4]), .cin(cout[31]), .sum(fa_out[32]), .cout(cout[32]));
	full_adder_module fa_34(.a(fa_out[22]), .b(out[5]), .cin(cout[32]), .sum(fa_out[33]), .cout(cout[33]));
	full_adder_module fa_35(.a(fa_out[25]), .b(out[6]), .cin(cout[33]), .sum(fa_out[34]), .cout(cout[34]));
	full_adder_module fa_36(.a(fa_out[27]), .b(out[7]), .cin(cout[34]), .sum(fa_out[35]), .cout(cout[35]));
	
	// contain clk, rst, accumulator 
	// store output value in d ff
	d_flip_flop_module out_1(.d(fa_out[28]), .clk(clk), .rst(rst), .q(out[0]), .q_bar(q_bar[0]));	
	d_flip_flop_module out_2(.d(fa_out[29]), .clk(clk), .rst(rst), .q(out[1]), .q_bar(q_bar[1]));
	d_flip_flop_module out_3(.d(fa_out[30]), .clk(clk), .rst(rst), .q(out[2]), .q_bar(q_bar[2]));
	d_flip_flop_module out_4(.d(fa_out[31]), .clk(clk), .rst(rst), .q(out[3]), .q_bar(q_bar[3]));
	d_flip_flop_module out_5(.d(fa_out[32]), .clk(clk), .rst(rst), .q(out[4]), .q_bar(q_bar[4]));
	d_flip_flop_module out_6(.d(fa_out[33]), .clk(clk), .rst(rst), .q(out[5]), .q_bar(q_bar[5]));
	d_flip_flop_module out_7(.d(fa_out[34]), .clk(clk), .rst(rst), .q(out[6]), .q_bar(q_bar[6]));
	d_flip_flop_module out_8(.d(fa_out[35]), .clk(clk), .rst(rst), .q(out[7]), .q_bar(q_bar[7]));

	// out_a <= a
	d_flip_flop_module out_a_9(.d(a[0]), .clk(clk), .rst(rst), .q(out_a[0]), .q_bar(q_bar[8]));	
	d_flip_flop_module out_a_10(.d(a[1]), .clk(clk), .rst(rst), .q(out_a[1]), .q_bar(q_bar[9]));
	d_flip_flop_module out_a_11(.d(a[2]), .clk(clk), .rst(rst), .q(out_a[2]), .q_bar(q_bar[10]));
	d_flip_flop_module out_a_12(.d(a[3]), .clk(clk), .rst(rst), .q(out_a[3]), .q_bar(q_bar[11]));
	d_flip_flop_module out_a_13(.d(a[4]), .clk(clk), .rst(rst), .q(out_a[4]), .q_bar(q_bar[12]));
	d_flip_flop_module out_a_14(.d(a[5]), .clk(clk), .rst(rst), .q(out_a[5]), .q_bar(q_bar[13]));
	d_flip_flop_module out_a_15(.d(a[6]), .clk(clk), .rst(rst), .q(out_a[6]), .q_bar(q_bar[14]));
	d_flip_flop_module out_a_16(.d(a[7]), .clk(clk), .rst(rst), .q(out_a[7]), .q_bar(q_bar[15]));
	
	// out_b <= b
	d_flip_flop_module out_b_17(.d(b[0]), .clk(clk), .rst(rst), .q(out_b[0]), .q_bar(q_bar[16]));	
	d_flip_flop_module out_b_18(.d(b[1]), .clk(clk), .rst(rst), .q(out_b[1]), .q_bar(q_bar[17]));
	d_flip_flop_module out_b_19(.d(b[2]), .clk(clk), .rst(rst), .q(out_b[2]), .q_bar(q_bar[18]));
	d_flip_flop_module out_b_20(.d(b[3]), .clk(clk), .rst(rst), .q(out_b[3]), .q_bar(q_bar[19]));
	d_flip_flop_module out_b_21(.d(b[4]), .clk(clk), .rst(rst), .q(out_b[4]), .q_bar(q_bar[20]));
	d_flip_flop_module out_b_22(.d(b[5]), .clk(clk), .rst(rst), .q(out_b[5]), .q_bar(q_bar[21]));
	d_flip_flop_module out_b_23(.d(b[6]), .clk(clk), .rst(rst), .q(out_b[6]), .q_bar(q_bar[22]));
	d_flip_flop_module out_b_24(.d(b[7]), .clk(clk), .rst(rst), .q(out_b[7]), .q_bar(q_bar[23]));
	
	
endmodule 
