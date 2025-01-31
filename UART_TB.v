`timescale 1ns / 1ps

module UART_TB;

    // Parameters
    parameter CLK_FREQ = 1E6;
    parameter BAUD = 9600;

    // Signals
    reg clk = 0;
    reg rst_n = 1;
    reg [7:0] din_tx;
    reg data_update;
    reg rx = 1;

    wire tx;
    wire [7:0] dout_rx;
    wire done_tx;
    wire done_rx;

    integer i;
    integer j;

    // Instantiate the UART Top module
    UART_Top #(
        .clk_freq(CLK_FREQ),
        .baud(BAUD)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .din_tx(din_tx),
        .data_update(data_update),
        .tx(tx),
        .dout_rx(dout_rx),
        .done_tx(done_tx),
        .done_rx(done_rx)
    );

    // Clock generation
    always #5 clk = ~clk;
    reg [7:0] data_tx = 0;
    reg [7:0] data_rx = 0;
    
    // Test procedure
    initial begin
        // Initialize signals
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        
        for (i = 0; i < 10; i = i + 1) begin
            rst_n = 1;
            data_update = 1;
            din_tx = $urandom();
            
            wait (tx == 0);
            @(posedge uut.u_tx.uart_clk);
        
            for (j = 0; j < 8; j = j + 1) begin
                @(posedge uut.u_tx.uart_clk);
                data_tx = {tx, data_tx[7:1]};
            end
            @(posedge done_tx);
        end
        
        for (i = 0; i < 10; i = i + 1) begin
            rst_n = 1;
            data_update = 0;    
            rx = 1'b0;
        
            @(posedge uut.u_tx.uart_clk);    
        
            for (j = 0; j < 8; j = j + 1) begin
                @(posedge uut.u_tx.uart_clk);
                rx = $urandom;
                data_rx = {rx, data_rx[7:1]};   
            end  
        
            @(posedge done_rx);
        end
    end

endmodule
