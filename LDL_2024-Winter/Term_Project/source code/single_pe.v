
module single_pe(in11, in12, in13, in14, 
  in21, in22, in23, in24, 
  in31, in32, in33, in34, 
  in41, in42, in43, in44,
  fil11, fil12, fil13, 
  fil21, fil22, fil23, 
  fil31, fil32, fil33, clk, rst,
  c11, c12, c21, c22);


 input[7:0] in11, in12, in13, in14, 
  in21, in22, in23, in24, 
  in31, in32, in33, in34, 
  in41, in42, in43, in44,
  fil11, fil12, fil13, 
  fil21, fil22, fil23, 
  fil31, fil32, fil33;

  input clk, rst;
  output reg [7:0] c11, c12, c21, c22;
  
  reg rst_pe;
  reg [1:0] buff;
  
  wire [7:0] f[2:0][2:0];
  wire [7:0] in[0:3][0:3];
  reg [7:0] a_pe, b_pe;
  wire [7:0] out;

  assign {in[0][0], in[0][1], in[0][2], in[0][3], 
          in[1][0], in[1][1], in[1][2], in[1][3],
          in[2][0], in[2][1], in[2][2], in[2][3], 
          in[3][0], in[3][1], in[3][2], in[3][3]}
          
           = {in11, in12, in13, in14,
              in21, in22, in23, in24,
              in31, in32, in33, in34,
              in41, in42, in43, in44};

  assign {f[2][2], f[2][1], f[2][0], 
          f[1][2], f[1][1], f[1][0], 
          f[0][2], f[0][1], f[0][0]}
          
           = {fil11, fil12, fil13,
              fil21, fil22, fil23,
              fil31, fil32, fil33};
  
  
  integer count;
  
  pe_module single_pe(.a(a_pe), .b(b_pe), .clk(clk), .rst(rst_pe), .out(out), .out_a(),.out_b());
  
  always @(posedge clk, posedge rst)
  begin
    if(rst == 1'b1)
      begin
        rst_pe <= 1'b1;
        count <= 10'd0;
        c11 <= 10'd0; c12 <= 10'd0; c21 <=10'd0; c22 <= 10'd0;
        a_pe <= 8'd0; b_pe<= 8'd0;
        buff <= 2'b00;
      end
    else
      begin
      if (buff == 2'b10)
        buff = buff -1;
      else if(buff == 2'b01)
        begin
            case(count/9)
              1: c11 = out;
              2: c12 = out;
              3: c21 = out;
              4: c22 = out;
            endcase
            a_pe=8'd0; b_pe= 8'd0;
            rst_pe = 1'b1;
            buff = buff-1;
        end
      else if(rst_pe== 1'b1)
          rst_pe = 1'b0;
      else
        begin
          case(count)
          0:
            begin
              a_pe = in[0][0]; 
              b_pe = f[0][0];
            end
          1:
            begin
              a_pe = in[0][1]; 
              b_pe = f[0][1];
            end
          2:
            begin
              a_pe = in[0][2]; 
              b_pe = f[0][2];
            end
          3:
            begin
              a_pe = in[1][0]; 
              b_pe = f[1][0];
            end
          4:
            begin
              a_pe = in[1][1]; 
              b_pe = f[1][1];
            end
          5:
            begin
              a_pe = in[1][2]; 
              b_pe = f[1][2];
            end
          6:
            begin
              a_pe = in[2][0]; 
              b_pe = f[2][0];
            end
          7:
            begin
              a_pe = in[2][1]; 
              b_pe = f[2][1];
            end
          8:
            begin
              a_pe = in[2][2]; 
              b_pe = f[2][2]; //result11
            end
          9:
            begin
              a_pe = in[0][1]; 
              b_pe = f[0][0];
            end
          10:
            begin
              a_pe = in[0][2]; 
              b_pe = f[0][1];
            end
          11:
            begin
              a_pe = in[0][3]; 
              b_pe = f[0][2];
            end
          12:
            begin
              a_pe = in[1][1]; 
              b_pe = f[1][0];
            end
          13:
            begin
              a_pe = in[1][2]; 
              b_pe = f[1][1];
            end
          14:
            begin
              a_pe = in[1][3]; 
              b_pe = f[1][2];
            end
          15:
            begin
              a_pe = in[2][1]; 
              b_pe = f[2][0];
            end
          16:
            begin
              a_pe = in[2][2]; 
              b_pe = f[2][1];
            end
          17:
            begin
              a_pe = in[2][3]; 
              b_pe = f[2][2]; //result12
            end
          18:
            begin
              a_pe = in[1][0]; 
              b_pe = f[0][0];
            end
          19:
            begin
              a_pe = in[1][1]; 
              b_pe = f[0][1];
            end
          20:
            begin
              a_pe = in[1][2]; 
              b_pe = f[0][2];
            end
          21:
            begin
              a_pe = in[2][0]; 
              b_pe = f[1][0];
            end
          22:
            begin
              a_pe = in[2][1]; 
              b_pe = f[1][1];
            end
          23:
            begin
              a_pe = in[2][2]; 
              b_pe = f[1][2];
            end
          24:
            begin
              a_pe = in[3][0]; 
              b_pe = f[2][0];
            end
          25:
            begin
              a_pe = in[3][1]; 
              b_pe = f[2][1];
            end
          26:
            begin
              a_pe = in[3][2]; 
              b_pe = f[2][2]; //result21
            end
          27:
            begin
              a_pe = in[1][1]; 
              b_pe = f[0][0];
            end
          28:
            begin
              a_pe = in[1][2]; 
              b_pe = f[0][1];
            end
          29:
            begin
              a_pe = in[1][3]; 
              b_pe = f[0][2];
            end
          30:
            begin
              a_pe = in[2][1]; 
              b_pe = f[1][0];
            end
          31:
            begin
              a_pe = in[2][2]; 
              b_pe = f[1][1];
            end
          32:
            begin
              a_pe = in[2][3]; 
              b_pe = f[1][2];
            end
          33:
            begin
              a_pe = in[3][1]; 
              b_pe = f[2][0];
            end
          34:
            begin
              a_pe = in[3][2]; 
              b_pe = f[2][1];
            end
          35:
            begin
              a_pe = in[3][3]; 
              b_pe = f[2][2]; //result22
            end
         
          endcase     
         count = count + 1;
         if (count != 1'b0 && count % 9 == 0)
           buff <= 2'b10;
        end   
      end
    end
endmodule
