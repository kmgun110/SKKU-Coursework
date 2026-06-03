module top_module (clk, rst, number, out);
  input clk, rst;
  output [7:0] number;
  output [7:0] out;

  // 4x4 input array
  reg [7:0] a11, a12, a13, a14;
  reg [7:0] a21, a22, a23, a24;
  reg [7:0] a31, a32, a33, a34;
  reg [7:0] a41, a42, a43, a44; 

  // 3x3 filter array
  reg [7:0] f11, f12, f13;
  reg [7:0] f21, f22, f23;
  reg [7:0] f31, f32, f33;

  wire enable_memory;
  wire enable_compute;
  wire enable_display;
  
  // 4x4 input memory
  wire [7:0] a11_mem, a12_mem, a13_mem, a14_mem;
  wire [7:0] a21_mem, a22_mem, a23_mem, a24_mem;
  wire [7:0] a31_mem, a32_mem, a33_mem, a34_mem;
  wire [7:0] a41_mem, a42_mem, a43_mem, a44_mem;

  wire [7:0] f11_mem, f12_mem, f13_mem;
  wire [7:0] f21_mem, f22_mem, f23_mem;
  wire [7:0] f31_mem, f32_mem, f33_mem;
    
 
  wire [7:0] c3x3_11, c3x3_12, c3x3_21, c3x3_22;
  wire [7:0] c2x2_11, c2x2_12, c2x2_21, c2x2_22;
  wire [7:0] single11, single12, single21, single22;
  
  wire [7:0] out;
  wire [7:0] number;

  initial 
  begin
    //input value
    a11 = 8'd1; a12 = 8'd3; a13 = 8'd5; a14 = 8'd7;
    a21 = 8'd9; a22 = 8'd11; a23 = 8'd13; a24 = 8'd15;
    a31 = 8'd17; a32 = 8'd19; a33 = 8'd21; a34 = 8'd23;
    a41 = 8'd25; a42 = 8'd27; a43 = 8'd29; a44 = 8'd31;

    f11 = 8'd9; f12 = 8'd8; f13 = 8'd7;
    f21 = 8'd6; f22 = 8'd5; f23 = 8'd4;
    f31 = 8'd3; f32 = 8'd2; f33 = 8'd1; 
  end

// instantiation
  // controller
  controller_module controller(.clk(clk), .rst(rst), .en_mem(enable_memory), .en_comp(enable_compute), .en_disp(enable_display));

  // memory
  
  // input array 4x4
  memory_module memory_matrix(.clk(clk), .rst(enable_memory), .control(1'b1),
  .arr_in0(a11), .arr_in1(a12), .arr_in2(a13), .arr_in3(a14),
  .arr_in4(a21), .arr_in5(a22), .arr_in6(a23), .arr_in7(a24),
  .arr_in8(a31), .arr_in9(a32), .arr_in10(a33), .arr_in11(a34),
  .arr_in12(a41), .arr_in13(a42), .arr_in14(a43), .arr_in15(a44),
  .arr_out0(a11_mem), .arr_out1(a12_mem), .arr_out2(a13_mem), .arr_out3(a14_mem),
  .arr_out4(a21_mem), .arr_out5(a22_mem), .arr_out6(a23_mem), .arr_out7(a24_mem),
  .arr_out8(a31_mem), .arr_out9(a32_mem), .arr_out10(a33_mem), .arr_out11(a34_mem),
  .arr_out12(a41_mem), .arr_out13(a42_mem), .arr_out14(a43_mem), .arr_out15(a44_mem));  
     
  // filter array 3x3
  memory_module memory_filter(.clk(clk), .rst(enable_memory), .control(1'b0), 
  .arr_in0(f11), .arr_in1(f12), .arr_in2(f13), 
  .arr_in3(f21), .arr_in4(f22), .arr_in5(f23), 
  .arr_in6(f31), .arr_in7(f32), .arr_in8(f33),
  .arr_in9(), .arr_in10(), .arr_in11(),
  .arr_in12(), .arr_in13(), .arr_in14(), .arr_in15(),
  .arr_out0(f11_mem), .arr_out1(f12_mem), .arr_out2(f13_mem), 
  .arr_out3(f21_mem), .arr_out4(f22_mem), .arr_out5(f23_mem), 
  .arr_out6(f31_mem), .arr_out7(f32_mem), .arr_out8(f33_mem), 
  .arr_out9(), .arr_out10(), .arr_out11(),
  .arr_out12(), .arr_out13(), .arr_out14(),
  .arr_out15());

  // Single_PE computation
  single_pe single_pe(.in11(a11_mem), .in12(a12_mem), .in13(a13_mem), .in14(a14_mem), 
  .in21(a21_mem), .in22(a22_mem), .in23(a23_mem), .in24(a24_mem), 
  .in31(a31_mem), .in32(a32_mem), .in33(a33_mem), .in34(a34_mem), 
  .in41(a41_mem), .in42(a42_mem), .in43(a43_mem), .in44(a44_mem),
  .fil11(f11_mem), .fil12(f12_mem), .fil13(f13_mem), 
  .fil21(f21_mem), .fil22(f22_mem), .fil23(f23_mem), 
  .fil31(f31_mem), .fil32(f32_mem), .fil33(f33_mem), .clk(clk), .rst(enable_compute),
  .c11(single11), .c12(single12), .c21(single21), .c22(single22));
 
  // systolic array 3x3 computation 
  systolic_three_by_three_module Systolic_3by3(.in11(a11_mem), .in12(a12_mem), .inp13(a13_mem), .in14(a14_mem), 
  .in21(a21_mem), .in22(a22_mem), .in23(a23_mem), .in24(a24_mem), 
  .in31(a31_mem), .inp32(a32_mem), .in33(a33_mem), .in34(a34_mem), 
  .in41(a41_mem), .in42(a42_mem), .in43(a43_mem), .in44(a44_mem),
  .fil11(f11_mem), .fil12(f12_mem), .fil13(f13_mem), 
  .fil21(f21_mem), .fil22(f22_mem), .fil23(f23_mem), 
  .fil31(f31_mem), .fil32(f32_mem), .fil33(f33_mem), 
  .clk(clk), .rst(enable_compute),
  .c11(c3x3_11), .c12(c3x3_12), .c21(c3x3_21), .c22(c3x3_22));

  // systolic array 2x2 computation
  systolic_two_by_two_module Systolic_2by2(.in11(a11_mem), .in12(a12_mem), .in13(a13_mem), .in14(a14_mem), 
  .in21(a21_mem), .in22(a22_mem), .in23(a23_mem), .in24(a24_mem), 
  .in31(a31_mem), .in32(a32_mem), .in33(a33_mem), .in34(a34_mem), 
  .in41(a41_mem), .in42(a42_mem), .in43(a43_mem), .in44(a44_mem),
  .fil11(f11_mem), .fil12(f12_mem), .fil13(f13_mem), 
  .fil21(f21_mem), .fil22(f22_mem), .fil23(f23_mem), 
  .fil31(f31_mem), .fil32(f32_mem), .fil33(f33_mem), 
  .clk(clk), .rst(enable_compute),
  .c11(c2x2_11), .c12(c2x2_12), .c21(c2x2_21), .c22(c2x2_22));

  // display
  display_module display(.clk(clk), .rst(enable_display),
  .cell_3x3_11(c3x3_11), .cell_3x3_12(c3x3_12), .cell_3x3_21(c3x3_21), .cell_3x3_22(c3x3_22), 
  .cell_2x2_11(c2x2_11), .cell_2x2_12(c2x2_12), .cell_2x2_21(c2x2_21), .cell_2x2_22(c2x2_22), 
  .digit(number), .out(out));
  
endmodule