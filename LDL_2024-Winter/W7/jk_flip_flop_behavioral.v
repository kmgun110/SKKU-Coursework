module jk_flip_flop_behavioral_module (j, k, clk, q, q_bar);
  input j,k;
  input clk;

  output q, q_bar;
  reg q, q_bar;
  
  always @ (posedge clk)
  begin
    case({j, k})
      2'b00: begin q <= q; q_bar <= q_bar; end
      2'b01: begin q <= 1'b0; q_bar <= 1'b1; end
      2'b10: begin q <= 1'b1; q_bar <= 1'b0; end
      2'b11: begin q <= q_bar; q_bar <= q; end
      default: begin q <= 1'b0; q_bar <= 1'b1; end
    endcase
  end
endmodule