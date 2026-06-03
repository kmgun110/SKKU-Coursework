module t_flip_flop_behavioral_module (t, clk, q, q_bar);
  input t;
  input clk;
  
  output q, q_bar;
  reg q, q_bar;
  
  initial
  begin q<=1'b0; q_bar<=1'b1; end
    
  always @ (posedge clk)
  begin
    if (t == 1'b1)
      begin
        q <= q_bar;
        q_bar <= q;
      end
      
    else
      begin
        q <= q;
        q_bar <= q_bar;
      end
    end
endmodule
