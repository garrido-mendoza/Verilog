`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A
// Engineer: Diego Garrido-Mendoza
// Design Name: Median Filter
// Module Name: Data_Sort_Intf
// Description: The Median Filter is designed to determine the median value within 
// a set of data points. It is commonly used to eliminate noise from digital signals, 
// especially in image processing applications.  
//
// Data Input and Register Setup
// The FPGA will receive data inputs in a 3x3 matrix format, representing image data. 
// The data is shifted into registers with each clock cycle. 
// For example:
// - At the first clock cycle, data packet 3 shifts into register d11, data packet 6 
//   into register d21, and data packet 9 into register d31.
// - At the second clock cycle, data packet 3 shifts into register d12, data packet 6 
//   into register d22, and data packet 9 into register d32. Meanwhile, data packet 
//   2 shifts into register d11, data packet 5 into register d21, and data packet 8 
//   into register d31.
//
// Sorting the Data
// Once all the data is received and stored in the registers, the next step is to sort the data. 
// The sorting process involves:
// - Finding the maximum, median, and minimum values for each row of the matrix.
//   For example:
//   - For the first row {1, 2, 3}, the sorted values are {3, 2, 1}. 
//   - For the second row {4, 5, 6}, the sorted values are {6, 5, 4}. 
//   - For the third row {7, 8, 9}, the sorted values are {9, 8, 7}.
//
// Finding the Median Value
// The final step is to find the median value for the entire matrix. This involves:
// - Finding the minimum value among the maximum values of each row.
// - Finding the median value among the median values of each row.
// - Finding the maximum value among the minimum values of each row.
//   For example, if the sorted rows are {3, 2, 1}, {6, 5, 4}, and {9, 8, 7}, the median 
//   value for the entire matrix is 5.
//
// Process:
// 1. Input the 3x3 matrix through d1_i, d2_i, and d3_i.
// 2. Divide the matrix into three rows:
//    - d11, d12, d13
//    - d21, d22, d23
//    - d31, d32, d33
// 3. Process each row to find the maximum, median, and minimum values:
//    - Row 1: max1, med1, min1
//    - Row 2: max2, med2, min2
//    - Row 3: max3, med3, min3
// 4. Calculate the minimum of the maximum values, the median of the median values, 
//    and the maximum of the minimum values:
//    - min of max: 3
//    - med of med: 5
//    - max of min: 7
// 5. Calculate the median of these three values to get the final median value: 5
//////////////////////////////////////////////////////////////////////////////////

module Median_Filter(
    input clk,
    input rst_n,
    input en_i,
    input [7:0] d1_i,
    input [7:0] d2_i,
    input [7:0] d3_i,
    output reg [7:0] done_o,    // Indicates to other modules that the median filtering was finished
    output [7:0] median_o
    );

    reg [7:0] d11, d12, d13;    // {1, 2, 3}
    reg [7:0] d21, d22, d23;    // {4, 5, 6}
    reg [7:0] d31, d32, d33;    // {7, 8, 9}    
    
    wire [7:0] max1, med1, min1;    // {3, 2, 1}
    wire [7:0] max2, med2, min2;    // {6, 5, 4}
    wire [7:0] max3, med3, min3;    // {9, 8, 7}
    
    wire [7:0] min_of_max;  // {3}
    wire [7:0] med_of_med;  // {5}
    wire [7:0] max_of_min;  // {7}
    
    reg hold;   // The hold signal ensures that the circuit is enabled only when needed, preventing unnecessary operations.
                // It helps in managing the state of the module, particularly in determining when to start and stop the filtering process.
    reg [3:0] count;
    
    //--------------------------------------------------------------------------------  
    // Data shift
    //-------------------------------------------------------------------------------- 
    
    // Input channel d1_i.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d11 <= 8'd0;
            d12 <= 8'd0;
            d13 <= 8'd0;
        end else begin
            d11 <= d1_i;
            d12 <= d11;
            d13 <= d12;
        end
     end

    // Input channel d2_i.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d21 <= 8'd0;
            d22 <= 8'd0;
            d23 <= 8'd0;
        end else begin
            d21 <= d2_i;
            d22 <= d21;
            d23 <= d22;
        end
     end    
      
    // Input channel d3_i.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d31 <= 8'd0;
            d32 <= 8'd0;
            d33 <= 8'd0;
        end else begin
            d31 <= d3_i;
            d32 <= d31;
            d33 <= d32;
        end
     end         
     
    //-------------------------------------------------------------------------------- 
    // Data sorting 
    //-------------------------------------------------------------------------------- 
    
    // Line 1.
    Data_Sort_Intf line1_sort(
       .clk(clk),
       .rst_n(rst_n),
       .d1_i(d11), // {1}
       .d2_i(d12), // {2}
       .d3_i(d13), // {3}
       .max_o(max1),   // {3}
       .med_o(med1),   // {2}
       .min_o(min1)    // {1}  
    );

    // Line 2.
    Data_Sort_Intf line2_sort(
       .clk(clk),
       .rst_n(rst_n),
       .d1_i(d21), // {4}
       .d2_i(d22), // {5}
       .d3_i(d23), // {6}
       .max_o(max2),   // {6}
       .med_o(med2),   // {5}
       .min_o(min2)    // {4}  
    );
    
    // Line 3.
    Data_Sort_Intf line3_sort(
       .clk(clk),
       .rst_n(rst_n),
       .d1_i(d31), // {7}
       .d2_i(d32), // {8}
       .d3_i(d33), // {9}
       .max_o(max3),   // {9}
       .med_o(med3),   // {8}
       .min_o(min3)    // {7}  
    );

    // Maximum.
    Data_Sort_Intf max_sort(
       .clk(clk),
       .rst_n(rst_n),
       .d1_i(max1),    // {3}
       .d2_i(max2),    // {6}
       .d3_i(max3),    // {9}
       .max_o(),
       .med_o(),
       .min_o(min_of_max)  // {3}  
    );        
     
    // Medium.
    Data_Sort_Intf med_sort(
       .clk(clk),
       .rst_n(rst_n),
       .d1_i(med1),    // {2}
       .d2_i(med2),    // {5}
       .d3_i(med3),    // {8}
       .max_o(),
       .med_o(med_of_med),  // {5} 
       .min_o()   
    );           

    // Minimum.
    Data_Sort_Intf min_sort(
       .clk(clk),
       .rst_n(rst_n),
       .d1_i(min1),    // {1}
       .d2_i(min2),    // {4}
       .d3_i(min3),    // {7}
       .max_o(max_of_min),  // {7}
       .med_o(),
       .min_o()    
    ); 

    //-------------------------------------------------------------------------------- 
    // Median Calculation:
    // - Calculate min of max values, med of med values, max of min values.
    // - Calculate the final median value using these three values with median_sort.
    //-------------------------------------------------------------------------------- 
    
    Data_Sort_Intf median_sort(
       .clk(clk),
       .rst_n(rst_n),
       .d1_i(min_of_max),  // {3}
       .d2_i(med_of_med),  // {5}
       .d3_i(max_of_min),  // {7}
       .max_o(),
       .med_o(median_o),   // {5}
       .min_o()  
    );
     
    //-------------------------------------------------------------------------------- 
    // Output signal handling.
    //-------------------------------------------------------------------------------- 
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hold <= 1'd0;    
            count <= 4'd0;
            done_o <= 1'd0;
        end else begin
            //-------------------------------------------------------------------------------- 
            // State management:
            // Managing the state and timing of the median filtering process.
            //-------------------------------------------------------------------------------- 
            case (hold)
                //-------------------------------------------------------------------------------- 
                // State 0: hold = 0. 
                // - done_o is set to 0 (indicating the process is not complete).
                // - If en_i (enable input) is high, the process starts:
                //   - hold is set to 1 (indicating the process is running).
                //   - count is incremented by 1.
                //--------------------------------------------------------------------------------  
                1'd0:
                    begin
                        done_o <= 1'd0;
                        if (en_i) begin
                            hold <= 1'd1;
                            count <= count + 4'd1;
                        end
                    end    
                //-------------------------------------------------------------------------------- 
                // State 1: hold = 1. 
                // - If count reaches 5, it means 6 clock cycles have passed (from 0 to 5), indicating 
                //   the process is complete:
                //   - hold is set to 0 (indicating the process is not running).
                //   - count is reset to 0.
                //   - done_o is set to 1 (indicating the process is finished).
                //--------------------------------------------------------------------------------  
                1'd1:
                    if (count == 4'd5) begin    // From 0 to 5 it's 6 clocks. 
                        hold <= 1'd0;
                        count <= 4'd0;
                        done_o <= 1'd1;
                    end else begin
                        count <= count + 4'd1;
                    end                   
                //-------------------------------------------------------------------------------- 
                // Default state: 
                // Ensures that if none of the above conditions are met, hold = 0, count = 0 (reset),
                // and done_o = 0 (safety mechanism).  
                //--------------------------------------------------------------------------------                               
                default:
                    begin 
                        hold <= 1'd0;
                        count <= 4'd0;
                        done_o <= 1'd0;
                    end
            endcase        
        end                                
    end
endmodule