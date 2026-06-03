`timescale 1ns/1ns

module top_tb;
  
  reg top_clk; 
  reg top_rst; 
  wire [7:0] top_out;
  wire [7:0] top_num;
  
  top_module top(.clk(top_clk),.rst(top_rst),.number(top_num),.out(top_out));
  
  //clock
  initial 
  begin 
    forever
    begin  
      #10 top_clk = !top_clk;
    end
  end
  // initial reset
  initial 
  begin 

    top_rst = 1'b1;
    top_clk = 1'b0;
    
  // top module start
    #10 top_rst = 1'b0;
  end
  
endmodule
    
