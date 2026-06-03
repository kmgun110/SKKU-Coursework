module systolic_three_by_three_module(
   input [7:0] in11, in12, in13, in14, in21, in22, in23,
  in24, in31, in32, in33, in34, in41, in42, in43, in44,
  input [7:0] fil11, fil12, fil13, fil21, fil22, fil23, fil31, fil32, fil33,
  input clk, rst, 
  output reg [7:0] c11, c12, c21, c22
  );

  //parameter ZERO = 8'd0; // 8-bit zero
  //parameter NEEDED_CYCLES = 4'd11; // 11 clock cycles needed for the 2 x 2 systolic array

  wire [7:0] in_1[0:10], in_2[0:10], in_3[0:10], fil_1[0:10], fil_2[0:10], fil_3[0:10]; // input values from inputs and filters
  reg [7:0] row_a, row_b, row_c, col_a, col_b, col_c; // register for entrance of inputs and filters
  wire [7:0] out_1, out_2, out_3, out_4; // a result through PE calculation
  wire [7:0] temp_row11, temp_row12, temp_row21, temp_row22, temp_row31, temp_row32, temp_col11, temp_col12, temp_col13, temp_col21, temp_col22, temp_col23; // temporary storage for a and b
  reg [4:0] cnt; // counter for timing prediction

   assign {in_1[0], in_1[1], in_1[2],
           in_1[3], in_1[4], in_1[5], 
           in_1[6], in_1[7], in_1[8], 
           in_1[9], in_1[10]}
          
       = {in11, in12, in13, 
          in21, in22, in23,
          in31, in32, in33,
          8'd0, 8'd0};
          
  assign {in_2[0], in_2[1], in_2[2], 
          in_2[3], in_2[4], in_2[5], 
          in_2[6], in_2[7], in_2[8], 
          in_2[9], in_2[10]}
          
       = {8'd0, in12, in13, 
          in14, in22, in23, 
          in24, in32, in33, 
          in34, 8'd0};
          
  assign {in_3[0], in_3[1], in_3[2], 
          in_3[3], in_3[4], in_3[5], 
          in_3[6], in_3[7], in_3[8], 
          in_3[9], in_3[10]}
          
       = {8'd0, in33, in32, 
          in31, in23, in22, 
          in21, in13, in12, 
          in11, 8'd0};
          
 assign {fil_1[0], fil_1[1], fil_1[2],
         fil_1[3], fil_1[4], fil_1[5],
         fil_1[6], fil_1[7], fil_1[8], 
         fil_1[9], fil_1[10]}
          
       = {fil33, fil32, fil31,
          fil23, fil22, fil21,
          fil13, fil12, fil11,
          8'd0, 8'd0};
          
 assign {fil_2[0], fil_2[1], fil_2[2], 
         fil_2[3], fil_2[4], fil_2[5],
         fil_2[6], fil_2[7], fil_2[8], 
         fil_2[9], fil_2[10]}
          
       = {in21, in22, in23,
          in31, in32, in33,
          in41, in42, in43,
          8'd0, 8'd0};
          
 assign {fil_3[0], fil_3[1], fil_3[2], 
         fil_3[3], fil_3[4], fil_3[5],
         fil_3[6], fil_3[7], fil_3[8], 
         fil_3[9], fil_3[10]}
          
       = {8'd0, in22, in23,
          in24, in32, in33,
          in34, in42, in43,
          in44, 8'd0};

  /*

  assign fil1[0] = filter33; assign fil1[1] = filter32; assign fil1[2] = filter31; assign fil1[3] = filter23;
  assign fil1[4] = filter22; assign fil1[5] = filter21; assign fil1[6] = filter13; assign fil1[7] = filter12;
  assign fil1[8] = filter11; assign fil1[9] = ZERO; assign fil1[10] = ZERO;

  assign fil2[0] = input21; assign fil2[1] = input22; assign fil2[2] = input23; assign fil2[3] = input31;
  assign fil2[4] = input32; assign fil2[5] = input33; assign fil2[6] = input41; assign fil2[7] = input42;
  assign fil2[8] = input43; assign fil2[9] = ZERO; assign fil2[10] = ZERO;

  assign fil3[0] = ZERO; assign fil3[1] = input22; assign fil3[2] = input23; assign fil3[3] = input24;
  assign fil3[4] = input32; assign fil3[5] = input33; assign fil3[6] = input34; assign fil3[7] = input42;
  assign fil3[8] = input43; assign fil3[9] = input44; assign fil3[10] = ZERO;*/

  // PE modules for processing
  pe_module PE1(.a(row_a), .b(col_a), .clk(clk), .rst(rst), .out(out_1), .out_a(temp_row11), .out_b(temp_col11));
  pe_module PE2(.a(temp_row11), .b(col_b), .clk(clk), .rst(rst), .out(), .out_a(temp_row12), .out_b(temp_col12));
  pe_module PE3(.a(temp_row12), .b(col_c), .clk(clk), .rst(rst), .out(), .out_a(), .out_b(temp_col13));
  pe_module PE4(.a(row_b), .b(temp_col11), .clk(clk), .rst(rst), .out(out_2), .out_a(temp_row21), .out_b(temp_col21));
  pe_module PE5(.a(temp_row21), .b(temp_col12), .clk(clk), .rst(rst), .out(), .out_a(temp_row22), .out_b(temp_col22));
  pe_module PE6(.a(temp_row22), .b(temp_col13), .clk(clk), .rst(rst), .out(), .out_a(), .out_b(temp_col23));
  pe_module PE7(.a(row_c), .b(temp_col21), .clk(clk), .rst(rst), .out(), .out_a(temp_row31), .out_b());
  pe_module PE8(.a(temp_row31), .b(temp_col22), .clk(clk), .rst(rst), .out(out_3), .out_a(temp_row32), .out_b());
  pe_module PE9(.a(temp_row32), .b(temp_col23), .clk(clk), .rst(rst), .out(out_4), .out_a(), .out_b());
  
  // On each clock rise
  always @(posedge clk or posedge rst)
  begin
    if(rst)
      begin
        cnt <= 8'd0;
        row_a <= 8'd0;
        row_b <= 8'd0;
        row_c <= 8'd0;
        col_a <= 8'd0;
        col_b <= 8'd0;
        col_c <= 8'd0;
      end
    else
    begin
      if (cnt <= 4'd11)
        begin
        cnt <= cnt + 1;
        row_a <= in_1[cnt];
        row_b <= in_2[cnt];
        row_c <= in_3[cnt]; 
        col_a <= fil_1[cnt];
        col_b <= fil_2[cnt];
        col_c <= fil_3[cnt];
        end
      else
        begin
        row_a <= 8'd0;
        row_b <= 8'd0;
        row_c <= 8'd0;
        col_a <= 8'd0;
        col_b <= 8'd0;
        col_c <= 8'd0;
        end
     end
  end

  always @(rst or out_1 or out_2 or out_3 or out_4)
  begin
    if(rst)
      begin
        c11 <= 8'd0;
        c12 <= 8'd0;
        c21<= 8'd0;
        c22<= 8'd0;
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