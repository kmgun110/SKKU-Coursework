`timescale 1ns/1ns

module tb_two_by_two;
  reg clk;
  reg rst; 
  reg[7:0] A11, A12, A13, A14, 
  A21, A22, A23, A24, 
  A31, A32, A33, A34, 
  A41, A42, A43, A44,
  B11, B12, B13, 
  B21, B22, B23, 
  B31, B32, B33;

  
  wire [7:0] C11, C12, C21, C22;
  
  systolic_two_by_two_module sys_two_by_two(.in11(A11), .in12(A12), .in13(A13), .in14(A14),
    .in21(A21), .in22(A22), .in23(A23), .in24(A24),
    .in31(A31), .in32(A32), .in33(A33), .in34(A34),
    .in41(A41), .in42(A42), .in43(A43), .in44(A44),
    .fil11(B11), .fil12(B12), .fil13(B13),
    .fil21(B21), .fil22(B22), .fil23(B23),
    .fil31(B31), .fil32(B32), .fil33(B33),
    .clk(CLK), .rst(RST),
    .c11(C11), .c12(C12), .c21(C21), .c22(C22)
    );
  
  initial
  begin
      A11 = 8'd1; A12 = 8'd2; A13 = 8'd3; A14 = 8'd4;
        A21 = 8'd5; A22 = 8'd6; A23 = 8'd7; A24 = 8'd8;
        A31 = 8'd9; A32 = 8'd10; A33 = 8'd11; A34 = 8'd12;
        A41 = 8'd13; A42 = 8'd14; A43 = 8'd15; A44 = 8'd16;
        B11 = 8'd1; B12 = 8'd1; B13 = 8'd1;
        B21 = 8'd1; B22 = 8'd1; B23 = 8'd1;
        B31 = 8'd1; B32 = 8'd1; B33 = 8'd1;

      
      rst = 1'b1; 
      clk = 1'b0;
  end
  
  initial
  begin
        forever
        begin
          #10 clk = !clk;
        end
  end

  initial
  begin
        #50 rst = 1'b0;
        #480 rst = 1'b1;

        #20 rst = 1'b0;
        #400 rst = 1'b1;
  end

endmodule













