module controller_module(input clk, input rst, 
output reg en_mem, output reg en_comp, 
output reg en_disp);

  reg [1:0] state;
  reg [1:0] next_state;
  reg [9:0] cnt;
  
  // Declaring state parameters for the Moore Machine
  // RESET_STATE: Initial RESET STATE
  // S0: Memory State
  // S1: Computation State
  // S2: Display State 
  parameter RESET_STATE = 0, S0 = 1, S1 = 2, S2 = 3;
  
  // Determining transition from current state to next_state
  always @ (clk or rst)
  begin
    //(changed) time interval to 40, 50, 200
    case(state)
      RESET_STATE:
      begin
        next_state <= (cnt == 10'd40) ? S0 : RESET_STATE;        
      end
      S0: // Memory State
      begin
        next_state <= (cnt == 10'd50) ? S1 : S0;
      end
      S1: // Computation State
      begin
        next_state <= (cnt == 10'd200) ? S2 : S1;
      end
      S2: // Display State
      begin
        next_state <= S2;
      end
      default: // default state in case of unexpected input
      begin
        next_state <= RESET_STATE;
      end
    endcase
  end
    
  // Updating current state to next_state
  always @ (posedge rst or posedge clk)
  begin
    if(rst) // rst==1, reset on
    begin
        state <= RESET_STATE;
        cnt <= 10'd0;
    end
    else // rst==0, reset off, transition to next state
    begin
      state <= next_state;
      cnt <= cnt + 10'd10;
    end   
  end

  // Determining output based on current state
  always @(state)
  begin
    case (state)
      RESET_STATE: // initial reset state
      begin
       en_mem = 1;
       en_comp = 1;
       en_disp = 1;
      end
      S0: // enable memory
      begin 
       en_mem = 0;
       en_comp = 1;
       en_disp = 1;
      end
      S1: // enable computation
      begin
       en_mem = 0;
       en_comp = 0;
       en_disp = 1;
      end
      S2: // enable display
      begin
       en_mem = 0;
       en_comp = 0;
       en_disp = 0;
      end
    endcase
  end

endmodule
  