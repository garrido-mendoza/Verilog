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
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module Data_Sort_Intf(
    input clk,
    input rst_n,
    input [7:0] d1_i,
    input [7:0] d2_i,
    input [7:0] d3_i,
    output reg [7:0] max_o,
    output reg [7:0] med_o,
    output reg [7:0] min_o
    );
    
    //--------------------------------------------------------------------------------
    // Max Calculation: 
    // This always block determines the maximum value among the three inputs. If the 
    // reset signal is asserted (low), max_o is set to 0. Otherwise, it compares the 
    // inputs and assigns the maximum value to max_o.
    //--------------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            max_o <= 8'd0;
        else if (d1_i >= d2_i && d1_i >= d3_i)
            max_o <= d1_i;
        else if (d2_i >= d1_i && d2_i >= d3_i)
            max_o <= d2_i;
        else if (d3_i >= d1_i && d3_i >= d2_i)
            max_o <= d3_i;
    end
    
    //-------------------------------------------------------------------------------- 
    // Median Calculation: 
    // This always block determines the median value among the three inputs. If the 
    // reset signal is asserted, med_o is set to 0. Otherwise, it checks different 
    // conditions to find the middle value.
    //--------------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            med_o <= 8'd0;
        else if ((d1_i >= d2_i && d1_i <= d3_i) || (d1_i >= d3_i && d1_i <= d2_i))
            med_o <= d1_i;
        else if ((d2_i >= d1_i && d2_i <= d3_i) || (d1_i >= d3_i && d2_i <= d1_i))
            med_o <= d2_i;
        else if ((d3_i >= d1_i && d3_i <= d2_i) || (d3_i >= d2_i && d3_i <= d1_i))
            med_o <= d3_i;
    end
    
    //-------------------------------------------------------------------------------- 
    // Min Calculation: 
    // This always block determines the minimum value among the three inputs. If the 
    // reset signal is asserted, min_o is set to 0. Otherwise, it compares the inputs 
    // and assigns the minimum value to min_o.
    //-------------------------------------------------------------------------------- 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            min_o <= 8'd0;
        else if (d1_i <= d2_i && d1_i <= d3_i)
            min_o <= d1_i;
        else if (d2_i <= d1_i && d2_i <= d3_i)
            min_o <= d2_i;
        else if (d3_i <= d1_i && d3_i <= d2_i)
            min_o <= d3_i;
    end
    
endmodule
