module display_testbench;
  
  reg clk, rst;
  reg [7:0]cell_3x3_11, cell_3x3_12, cell_3x3_21, cell_3x3_22, cell_2x2_11, cell_2x2_12, cell_2x2_21, cell_2x2_22;
  
  wire [7:0]digit;
  wire [7:0]out;
  
    display_module test (
        .clk(clk),
        .rst(rst),
        .cell_3x3_11(cell_3x3_11),
        .cell_3x3_12(cell_3x3_12),
        .cell_3x3_21(cell_3x3_21),
        .cell_3x3_22(cell_3x3_22),
        .cell_2x2_11(cell_2x2_11),
        .cell_2x2_12(cell_2x2_12),
        .cell_2x2_21(cell_2x2_21),
        .cell_2x2_22(cell_2x2_22),
        .digit(digit),
        .out(out)
    );      
  initial
  begin
   clk = 1'b0;
   rst = 1'b1;
   cell_3x3_11 = 12;
   cell_3x3_12 = 34;
   cell_3x3_21 = 56;
   cell_3x3_22 = 78;
   cell_2x2_11 = 100;
   cell_2x2_12 = 1;
   cell_2x2_21 = 13;
   cell_2x2_22 = 8; 
  end
  
  initial
  begin
    forever
      #10 clk = !clk;
  end
  
  initial
  begin
    #100 rst = 1'b0;
  end
  
endmodule
