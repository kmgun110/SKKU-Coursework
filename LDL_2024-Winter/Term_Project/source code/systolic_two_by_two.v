module systolic_two_by_two_module(
  input [7:0] in11, in12, in13, in14, in21, in22, in23,
  in24, in31, in32, in33, in34, in41, in42, in43, in44,
  input [7:0] fil11, fil12, fil13, fil21, fil22, fil23, fil31, fil32, fil33,
  input clk, rst, 
  output reg [7:0] c11, c12, c21, c22
  );
  
  //parameter ZERO = 8'd0; // 8-bit zero
  //parameter NEEDED_CYCLES = 4'd14; // 14 clock cycles needed for the 2 x 2 systolic array calculation

  wire [7:0] in_1[0:13], in_2[0:13], fil_1[0:13], fil_2[0:13]; // input values from inputs and filters
  reg [7:0] row_a, row_b, col_a, col_b; // register for entrance of inputs and filters
  wire [7:0] out_1, out_2, out_3, out_4; // a result through PE calculation
  wire [7:0] temp_row11, temp_row21, temp_col11, temp_col12; // temporary storage for a and b
  reg [4:0] cnt; // counter for timing prediction

  // Assigning values to inputs and filter in order to calculate the output
  assign {in_1[0], in_1[1], in_1[2], in_1[3], 
          in_1[4], in_1[5], in_1[6], in_1[7], 
          in_1[8], in_1[9], in_1[10], in_1[11], 
          in_1[12], in_1[13]}
          
       = {in11, in12, in13, in14,
          in21, in22, in23, in24,
          in31, in32, in33, in34,
          8'd0, 8'd0};
          
  assign {in_2[0], in_2[1], in_2[2], in_2[3], 
          in_2[4], in_2[5], in_2[6], in_2[7], 
          in_2[8], in_2[9], in_2[10], in_2[11], 
          in_2[12], in_2[13]}
          
       = {8'd0, in21, in22, in23,
          in24, in31, in32, in33,
          in34, in41, in42, in43,
          in44, 8'd0};
          
 assign {fil_1[0], fil_1[1], fil_1[2], fil_1[3], 
          fil_1[4], fil_1[5], fil_1[6], fil_1[7], 
          fil_1[8], fil_1[9], fil_1[10], fil_1[11], 
          fil_1[12], fil_1[13]}
          
       = {fil33, fil32, fil31, 8'd0,
          fil23, fil22, fil21, 8'd0,
          fil13, fil12, fil11, 8'd0,
          8'd0, 8'd0};
          
 assign {fil_2[0], fil_2[1], fil_2[2], fil_2[3], 
          fil_2[4], fil_2[5], fil_2[6], fil_2[7], 
          fil_2[8], fil_2[9], fil_2[10], fil_2[11], 
          fil_2[12], fil_2[13]}
          
       = {8'd0, 8'd0, fil33, fil32,
          fil31, 8'd0, fil23, fil22,
          fil21, 8'd0, fil13, fil12,
          fil11, 8'd0};
       
/*  assign in1[0] = in11; assign in1[1] = in12; assign in1[2] = in13; assign in1[3] = in14;
  assign in1[4] = input21; assign in1[5] = input22; assign in1[6] = input23; assign in1[7] = input24;
  assign in1[8] = input31; assign in1[9] = input32; assign in1[10] = input33; assign in1[11] = input34;
  assign in1[12] = ZERO; assign in1[13] = ZERO;*/

 /* assign in2[0] = ZERO; assign in2[1] = input21; assign in2[2] = input22; assign in2[3] = input23;
  assign in2[4] = input24; assign in2[5] = input31; assign in2[6] = input32; assign in2[7] = input33;
  assign in2[8] = input34; assign in2[9] = input41; assign in2[10] = input42; assign in2[11] = input43;
  assign in2[12] = input44; assign in2[13] = ZERO;*/

  /*assign fil1[0] = filter33; assign fil1[1] = filter32; assign fil1[2] = filter31; assign fil1[3] = ZERO;
  assign fil1[4] = filter23; assign fil1[5] = filter22; assign fil1[6] = filter21; assign fil1[7] = ZERO;
  assign fil1[8] = filter13; assign fil1[9] = filter12; assign fil1[10] = filter11;
  assign fil1[11] = ZERO; assign fil1[12] = ZERO; assign fil1[13] = ZERO;

  assign fil2[0] = ZERO; assign fil2[1] = ZERO; assign fil2[2] = filter33; assign fil2[3] = filter32;
  assign fil2[4] = filter31; assign fil2[5] = ZERO; assign fil2[6] = filter23; assign fil2[7] = filter22;
  assign fil2[8] = filter21; assign fil2[9] = ZERO; assign fil2[10] = filter13; assign fil2[11] = filter12;
  assign fil2[12] = filter11; assign fil2[13] = ZERO;*/

  // PE modules for processing
  pe_module PE1(.a(row_a), .b(col_a), .clk(clk), .rst(rst), .out(out_1), .out_a(temp_row11), .out_b(temp_col11));
  pe_module PE2(.a(temp_row11), .b(col_b), .clk(clk), .rst(rst), .out(out_2), .out_a(), .out_b(temp_col12));
  pe_module PE3(.a(row_b), .b(temp_col11), .clk(clk), .rst(rst), .out(out_3), .out_a(temp_row21), .out_b());
  pe_module PE4(.a(temp_row21), .b(temp_col12), .clk(clk), .rst(rst), .out(out_4), .out_a(), .out_b());

  // On each clock rise
  always @(posedge clk or posedge rst)
  begin
    if(rst)
      begin
        cnt <= 8'd0;
        row_a <= 8'd0;
        row_b <= 8'd0;
        col_a <= 8'd0;
        col_b <= 8'd0;
      end
    else
    begin
      if (cnt <= 4'd14)
        begin
        cnt <= cnt + 1;
        row_a <= in_1[cnt];
        row_b <= in_2[cnt];
        col_a <= fil_1[cnt];
        col_b <= fil_2[cnt];
        end
      else
        begin
        row_a <= 8'd0;
        row_b <= 8'd0;
        col_a <= 8'd0;
        col_b <= 8'd0;
        end
    end
  end
  
  always @(rst or out_1 or out_2 or out_3 or out_4)
  begin
    if(rst)
      begin
        c11 <= 8'd0;
        c12 <= 8'd0;
        c21 <= 8'd0;
        c22 <= 8'd0;
      end
    else
      begin
        c11 <= out_1;
        c12 <= out_2;
        c21 <= out_3;
        c22 <= out_4;
      end
  end
    
endmodule