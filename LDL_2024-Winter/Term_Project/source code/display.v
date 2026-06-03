module display_module(
    clk, rst, 
    cell_3x3_11, cell_3x3_12, cell_3x3_21, cell_3x3_22, 
    cell_2x2_11, cell_2x2_12, cell_2x2_21, cell_2x2_22, 
    digit, out
);

    input clk, rst;                         // Clock and Reset inputs
    input [7:0] cell_3x3_11, cell_3x3_12,   // 3x3 Cell inputs
               cell_3x3_21, cell_3x3_22,
               cell_2x2_11, cell_2x2_12,   // 2x2 Cell inputs
               cell_2x2_21, cell_2x2_22;

    output reg [7:0] digit, out;            // Outputs for digit and segment display

    reg [29:0] count;                       // Counter for sequencing cells
    reg [3:0] cellNum;                      // Selected cell number
    wire [7:0] cellWire [0:7];              // Array to hold cell values

    reg [3:0] segmentNumber;                // Selected segment number
    wire [1:0] flag;                        // Phase indicator for digit selection

    // Cell connection
    assign cellWire[0] = cell_3x3_11;
    assign cellWire[1] = cell_3x3_12;
    assign cellWire[2] = cell_3x3_21;
    assign cellWire[3] = cell_3x3_22;
    assign cellWire[4] = cell_2x2_11;
    assign cellWire[5] = cell_2x2_12;
    assign cellWire[6] = cell_2x2_21;
    assign cellWire[7] = cell_2x2_22;

    // Counter logic
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            count <= 30'b0;
            cellNum <= 4'd0;
        end else begin
            count <= count + 1;          // Increment the counter
            cellNum <= count[28:26];     // Cycle through the 8 cells
        end
    end

    // Flag generation for digit phases
    assign flag = count[19:18];

    // Digit selection and segment number extraction
    always @ (*) begin
        case (flag)
            2'b00: begin
                digit = 8'b00000000;  // Default digit
                segmentNumber = 4'b0000; // Default value
            end
            2'b01: begin
                digit = 8'b00000100;         // Hundreds digit phase
                segmentNumber = cellWire[cellNum] / 100;
            end
            2'b10: begin
                digit = 8'b00000010;         // Tens digit phase
                segmentNumber = (cellWire[cellNum] % 100) / 10;
            end
            2'b11: begin
                digit = 8'b00000001;         // Units digit phase
                segmentNumber = (cellWire[cellNum] % 100) % 10;
            end
        endcase
    end

    // Seven-segment display logic
    always @ (*) begin
        case(segmentNumber)
            4'b0000: out = 8'b00111111;  // Display 0
            4'b0001: out = 8'b00000110;  // Display 1
            4'b0010: out = 8'b01011011;  // Display 2
            4'b0011: out = 8'b01001111;  // Display 3
            4'b0100: out = 8'b01100110;  // Display 4
            4'b0101: out = 8'b01101101;  // Display 5
            4'b0110: out = 8'b01111101;  // Display 6
            4'b0111: out = 8'b00100111;  // Display 7
            4'b1000: out = 8'b01111111;  // Display 8
            4'b1001: out = 8'b01101111;  // Display 9
            default: out = 8'b00000000;  // Default case
        endcase
    end

endmodule