`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: N/A 
// Engineer: Diego Garrido-Mendoza 
// Module Name: Gaussian_Filter
//
// Description:
// The module takes three lines of 8-bit input data (d1_i, d2_i, d3_i), processes 
// it using a Gaussian kernel, and produces a filtered 8-bit output (gaussian_o). 
// The Gaussian filtering process consists of several steps, including data shifting, 
// data multiplication with the Gaussian kernel, summing the products, and dividing 
// the sum by 16 to get the final output. 
// 
// Additional Comments:
// Input data:       Data sorting:                 Data & Gaussian kernel products:     --
// | 1 | 2 | 3 | --> | d11=1 | d12=2 | d13=3 | --> | gs1= d11*1 + d12*2 + d13*1 = 8  |   |     Gaussian sum of products:           Gaussian output (divide by 16):      
// |---|---|---|     |-------|-------|-------|     |---------------------------------|   |      ----------------------------       ---------------------------- 
// | 4 | 5 | 6 | --> | d21=4 | d22=5 | d23=6 | --> | gs2= d21*2 + d22*4 + d23*2 = 40 |   | --> | gs_sum = 8 + 40 + 32 = 80  | --> | gaussian_o = 80 / 16 = 5  | 
// |---|---|---|     |-------|-------|-------|     |---------------------------------|   |      ----------------------------       ---------------------------- 
// | 7 | 8 | 9 | --> | d31=7 | d32=8 | d33=9 | --> | gs3= d31*1 + d32*2 + d33*1 = 32 |   |
//                                                                                      --
// Gaussian kernel:
// --         --
// | 1   2   1 |
// |           | 
// | 2   4   2 | / 16
// |           |
// | 1   2   1 |
// --         --
//////////////////////////////////////////////////////////////////////////////////

module Gaussian_Filter(
    input clk,
    input rst_n,
    input en_i,
    input [7:0] d1_i,   // Input data, line 1.
    input [7:0] d2_i,   // Input data, line 2.
    input [7:0] d3_i,   // Input data, line 3.
    output reg done_o,  // This indicates to other modules that the gaussian filtering has finished.
    output reg [7:0] gaussian_o 
    );
    
    //-------------------------------------------------------------------------------- 
    // Input data registers.
    //-------------------------------------------------------------------------------- 
    
    // Data line 1. Registers for {1, 2, 3}
    reg [7:0] d11;  // {1}
    reg [7:0] d12;  // {2}
    reg [7:0] d13;  // {3}
    
    // Data line 2. Registers for {4, 5, 6}
    reg [7:0] d21;  // {4}
    reg [7:0] d22;  // {5}
    reg [7:0] d23;  // {6}
    
    // Data line 3. Registers for {7, 8, 9}
    reg [7:0] d31;  // {7}
    reg [7:0] d32;  // {8}
    reg [7:0] d33;  // {9}      
    
    //-------------------------------------------------------------------------------- 
    // Convolution result registers. 
    //--------------------------------------------------------------------------------       
    
    reg [11:0] gs1;
    reg [11:0] gs2;
    reg [11:0] gs3;   
    reg [11:0] gs_sum;
    
    //-------------------------------------------------------------------------------- 
    // State machine registers. 
    //-------------------------------------------------------------------------------- 
    reg hold;   // The hold signal ensures that the circuit is enabled only when needed, preventing unnecessary operations.
                // It helps in managing the state of the module, particularly in determining when to start and stop the filtering process.
    reg [3:0] count;         
    
    //--------------------------------------------------------------------------------  
    // Data shift:
    // The input data is sequentially shifted into the registers over nine clock cycles 
    // after a reset. This helps in organizing the data for processing. 
    //-------------------------------------------------------------------------------- 
    
    // Input channel d1_i.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d11 <= 8'd0;
            d12 <= 8'd0;
            d13 <= 8'd0;
        end else begin
            d11 <= d1_i;    // One clock cycle after reset, d1_i input signal shifts into d11 
            d12 <= d11;     // One clock cycle later, d11 shifts into d12 
            d13 <= d12;     // One clock cycle later, d12 shifts into d13 
        end
    end
    
    // Input channel d2_i.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d21 <= 8'd0;
            d22 <= 8'd0;
            d23 <= 8'd0;
        end else begin
            d21 <= d2_i;    // One clock cycle after reset, d2_i input signal shifts into d21
            d22 <= d21;     // One clock cycle later, d21 shifts into d22                  
            d23 <= d22;     // One clock cycle later, d22 shifts into d23                  
        end
    end       
    
    // Input channel d3_i.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            d31 <= 8'd0;
            d32 <= 8'd0;
            d33 <= 8'd0;
        end else begin
            d31 <= d3_i;    // One clock cycle after reset, d3_i input signal shifts into d31
            d32 <= d31;     // One clock cycle later, d31 shifts into d32                    
            d33 <= d32;     // One clock cycle later, d32 shifts into d33                    
        end
    end  

    //--------------------------------------------------------------------------------  
    // Data & Gaussian kernel products:
    // This is the 1st step of the convolution. The input data is multiplied by the 
    // Gaussian kernel weights. The multiplication results are stored in three registers 
    // (gs1, gs2, gs3) 
    //-------------------------------------------------------------------------------- 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gs1 <= 12'd0;
            gs2 <= 12'd0;
            gs3 <= 12'd0;
        end else begin                      // These are running at the same time:
            gs1 <= d11*1 + d12*2 + d13*1;   // gs1= d11*1 + d12*2 + d13*1 = 8     
            gs2 <= d21*2 + d22*4 + d23*2;   // gs2= d21*2 + d22*4 + d23*2 = 40     
            gs3 <= d31*1 + d32*2 + d33*1;   // gs3= d31*1 + d32*2 + d33*1 = 32     
        end
    end
    
    //--------------------------------------------------------------------------------  
    // Gaussian sum of products:
    // This is the 2nd step of the convolution. The partial results are summed up into 
    // a single value (gs_sum).
    //-------------------------------------------------------------------------------- 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gs_sum <= 12'd0;
        end else begin                      
            gs_sum <= gs1 + gs2 + gs3;   // gs1= d11*1 + d12*2 + d13*1 = 8
        end
    end

    //--------------------------------------------------------------------------------  
    // Gaussian output (divide by 16):
    // This is the 3rd step of the convolution. The sum of products is divided by 16 
    // (accomplished by a bitwise right shift of 4) to produce the final Gaussian-filtered 
    // output (gaussian_o).
    //-------------------------------------------------------------------------------- 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gaussian_o <= 8'd0;
        end else begin                      
            gaussian_o <= gs_sum >> 4;   // By shifting the data bus 4 bits to the righ, we divide by 16.
        end
    end
    
    //--------------------------------------------------------------------------------  
    // Output signal handling..
    //-------------------------------------------------------------------------------- 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hold <= 1'd0;    
            count <= 4'd0;
            done_o <= 1'd0;
        end else begin
            //-------------------------------------------------------------------------------- 
            // State management:
            // A state machine manages the filtering process, ensuring the module operates 
            // correctly, starts, and completes the filtering process as needed. The done_o 
            // signal indicates when the filtering process is finished.
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
