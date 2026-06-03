module memory_module(input clk, input rst, input control, 
                     input [7:0] arr_in0, arr_in1, arr_in2, arr_in3,
                     arr_in4, arr_in5, arr_in6, arr_in7,
                     arr_in8, arr_in9, arr_in10, arr_in11,
                     arr_in12, arr_in13, arr_in14, arr_in15,
                     output reg [7:0] arr_out0, arr_out1, arr_out2, arr_out3,
                     arr_out4, arr_out5, arr_out6, arr_out7,
                     arr_out8, arr_out9, arr_out10, arr_out11,
                     arr_out12, arr_out13, arr_out14, arr_out15);
  
  integer i; // Declaring integer counter (for loop iteration)

  // Declaring reg for input data
  reg [7:0] storage[15:0];
  reg [7:0] matrix[15:0];
  reg [7:0] filter[8:0];

  always @(posedge clk)
  begin  
    // Storing input data
    {storage[0], storage[1], storage[2], storage[3],
    storage[4], storage[5], storage[6], storage[7], 
    storage[8], storage[9], storage[10], storage[11], 
    storage[12], storage[13], storage[14], storage[15]} =  {arr_in0, arr_in1, arr_in2, arr_in3,
                                                            arr_in4, arr_in5, arr_in6, arr_in7,
                                                            arr_in8, arr_in9, arr_in10, arr_in11,
                                                            arr_in12, arr_in13, arr_in14, arr_in15}; 
    case (rst)
    // if rst == 0 (reset is off) 
    1'b0:
    begin
        if(!control)         
        begin
        // if control == 0, giving 3x3 filter to output
        
          // Saving data to filter array
          for (i = 0; i < 9; i = i + 1)
          begin
            filter[i] = storage[i];
          end

          // Assigning values of filter to corresponding output 
          // Setting unnecessary values to 0
          {arr_out0, arr_out1, arr_out2, arr_out3} = {filter[0], filter[1], filter[2], filter[3]};
          {arr_out4, arr_out5, arr_out6, arr_out7} = {filter[4], filter[5], filter[6], filter[7]};
          {arr_out8, arr_out9, arr_out10, arr_out11} = {filter[8], 8'd0, 8'd0, 8'd0};
          {arr_out12, arr_out13, arr_out14, arr_out15} = {8'd0, 8'd0, 8'd0, 8'd0};
        end
        else
        begin
        // if control == 1, giving 4x4 matrix to output

          // Saving data to matrix array
          for (i = 0; i < 16; i = i + 1)
          begin
            matrix[i] = storage[i];
          end

          // Assigning values of matrix to corresponding output
          {arr_out0, arr_out1, arr_out2, arr_out3} = {matrix[0], matrix[1], matrix[2], matrix[3]};
          {arr_out4, arr_out5, arr_out6, arr_out7} = {matrix[4], matrix[5], matrix[6], matrix[7]};
          {arr_out8, arr_out9, arr_out10, arr_out11} = {matrix[8], matrix[9], matrix[10], matrix[11]};
          {arr_out12, arr_out13, arr_out14, arr_out15} = {matrix[12], matrix[13], matrix[14], matrix[15]};
        end
    end
    // if rst == 1 (reset is on)
    1'b1: 
    begin
      // Resetting matrix and filter elements to 0    
      for (i = 0; i < 16; i = i + 1) 
      begin
        if (i < 9)
        begin           
          filter[i] = 8'd0;
        end
        matrix[i] = 8'd0;
      end
      // Resetting output values to 0
      {arr_out0, arr_out1, arr_out2, arr_out3} = {8'd0, 8'd0, 8'd0, 8'd0};
      {arr_out4, arr_out5, arr_out6, arr_out7} = {8'd0, 8'd0, 8'd0, 8'd0};
      {arr_out8, arr_out9, arr_out10, arr_out11} = {8'd0, 8'd0, 8'd0, 8'd0};
      {arr_out12, arr_out13, arr_out14, arr_out15} = {8'd0, 8'd0, 8'd0, 8'd0};
    end
   endcase
  end

endmodule
