module memory_tb;
  
  reg rst, clk, control;
  reg [7:0] arr_in0, arr_in1, arr_in2, arr_in3,
  arr_in4, arr_in5, arr_in6, arr_in7,
  arr_in8, arr_in9, arr_in10, arr_in11,
  arr_in12, arr_in13, arr_in14, arr_in15;
  
  wire [7:0] arr_out0, arr_out1, arr_out2, arr_out3,
  arr_out4, arr_out5, arr_out6, arr_out7,
  arr_out8, arr_out9, arr_out10, arr_out11,
  arr_out12, arr_out13, arr_out14, arr_out15;

  //instantiating memory module
  memory_module memory(.clk(clk), .rst(rst), .control(control), 
  .arr_in0(arr_in0), .arr_in1(arr_in1), .arr_in2(arr_in2), .arr_in3(arr_in3),
   .arr_in4(arr_in4), .arr_in5(arr_in5), .arr_in6(arr_in6), .arr_in7(arr_in7),
    .arr_in8(arr_in8), .arr_in9(arr_in9), .arr_in10(arr_in10), .arr_in11(arr_in11),
     .arr_in12(arr_in12), .arr_in13(arr_in13), .arr_in14(arr_in14), .arr_in15(arr_in15),        
  .arr_out0(arr_out0), .arr_out1(arr_out1), .arr_out2(arr_out2), .arr_out3(arr_out3),
   .arr_out4(arr_out4), .arr_out5(arr_out5), .arr_out6(arr_out6), .arr_out7(arr_out7),
    .arr_out8(arr_out8), .arr_out9(arr_out9), .arr_out10(arr_out10), .arr_out11(arr_out11),
     .arr_out12(arr_out12), .arr_out13(arr_out13), .arr_out14(arr_out14), .arr_out15(arr_out15));

  // initiating clk
  initial
  begin
    forever
    begin 
      #10 clk = !clk;
    end
  end  
  
  initial
  begin // Initial Values
    rst = 1'b1; clk = 1'b0; control = 1'b1; //choosing matrix as output
    
    arr_in0 = 8'd0; arr_in1 = 8'd0; arr_in2 = 8'd0; arr_in3 = 8'd0;
    arr_in4 = 8'd0; arr_in5 = 8'd0; arr_in6 = 8'd0; arr_in7 = 8'd0;
    arr_in8 = 8'd0; arr_in9 = 8'd0; arr_in10 = 8'd0; arr_in11 = 8'd0;
    arr_in12 = 8'd0; arr_in13 = 8'd0; arr_in14 = 8'd0; arr_in15 = 8'd0;

  end

  //implementing test pattern below
  initial
  begin 
    #20 rst = 1'b0; //deactivating reset   

    // first input matrix
    arr_in0 = 1; arr_in1 = 2; arr_in2 = 3; arr_in3 = 4;
    arr_in4 = 5; arr_in5 = 6; arr_in6 = 7; arr_in7 = 8;
    arr_in8 = 9; arr_in9 = 10; arr_in10 = 11; arr_in11 = 12;
    arr_in12 = 13; arr_in13 = 14; arr_in14 = 15; arr_in15 = 16;
    
    #20 rst = 1'b1; control = 1'b0; //activating reset, choosing filter matrix as output  
    #20 rst = 1'b0; //deactivating reset 
    
    // second input matrix
    arr_in0 = 240; arr_in1 = 240; arr_in2 = 240; arr_in3 = 240;
    arr_in4 = 240; arr_in5 = 240; arr_in6 = 240; arr_in7 = 240;
    arr_in8 = 240; arr_in9 = 15; arr_in10 = 15; arr_in11 = 15;
    arr_in12 = 15; arr_in13 = 15; arr_in14 = 15; arr_in15 = 15;
    
    #20 rst = 1'b1;
  end
endmodule

