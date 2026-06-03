`timescale 1ns/1ns

module controller_tb;
  reg clk, rst;
  wire en_mem, en_comp, en_disp;
  
  controller_module controller(.clk(clk), .rst(rst), 
  .en_mem(en_mem), .en_comp(en_comp), .en_disp(en_disp));

  // initiating system clk (changing every 10ns)  
  initial 
  begin
    forever
    begin 
      #10 clk = !clk;
    end
  end
  
  // setting initial values for input
  initial
  begin
    clk = 1'b0;
    rst = 1'b1; // reset on
  end

  // implementing test plan
  initial
  begin
    #20 rst = 1'b0;
    #500 rst = 1'b1;
    #100 rst = 1'b0;
  end
  
endmodule


