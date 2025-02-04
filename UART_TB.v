module UART_TB;

    // Parameters
    parameter CLK_FREQ = 1E6;
    parameter BAUD = 9600;

    // Signals
    reg clk = 0;            // Clock signal                 
    reg rst_n = 1;          // Reset signal                 
    reg rx = 1;             // UART receive line (idle high)
    reg [7:0] din_tx = 0;   // Data to transmit             
    reg data_update = 0;    // New data signal              
    
    wire tx;                // UART transmit line           
    wire [7:0] dout_rx;     // Data received                
    wire done_tx;           // Transmission done signal     
    wire done_rx;           // Reception done signal        

    integer i = 0;          // Loop index for transmission  
    integer j = 0;          // Loop index for bit capturing 
    integer k = 0;          // Loop index for bit transmission

    // Instantiate the UART Top module with clock frequency and baud rate parameters
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

    // Clock generation: toggle the clock every 5 time units to create a 10 time units period clock
    always #5 clk = ~clk;
    
    reg [7:0] data_tx = 0;   // Temporary storage for transmitted data bits
    reg [7:0] data_rx = 0;   // Temporary storage for received data bits   
    
    // Test procedure
    initial begin
        // Initialize signals and reset the system
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
        
        // Transmission Test Loop
        $display("Starting UART Transmission Test");
        for (i = 0; i <= 10; i = i + 1) begin
            data_update = 1;                // Sets newd to indicate new data is available.                                  
            din_tx = $urandom();            // Generates a random byte of data (dintx) to be transmitted.
            
            wait (tx == 0);                 // Waits for the tx line to go low, signaling the start bit.
            @(posedge uut.u_tx.uart_clk);   // Waits for the positive edge of the UART clock.           
        
            // Initialize data_tx with the value of din_tx
            data_tx = din_tx;
            
            // Capture all 8 bits of the transmitted byte.
            for (j = 0; j < 8; j = j + 1) begin
                @(posedge uut.u_tx.uart_clk);
                data_tx = {tx, data_tx[7:1]};   // Shifts and stores the transmitted bit into data_tx.
            end
            @(posedge done_tx);                 // Waits for the transmission to complete (donetx goes high).
            $display("Transmitted Data: %h", din_tx);
            
            // Reception test
            data_rx = 0;
            
            // Start bit
            rx = 0;
            @(posedge uut.u_rx.uart_clk);
            
            // Data bits
            for (k = 0; k < 8; k = k + 1) begin
                rx = din_tx[k];
                @(posedge uut.u_rx.uart_clk);
                data_rx = {rx, data_rx[7:1]};   // Shift and store the received bit into data_rx.
            end
            
            // Stop bit
            rx = 1;
            @(posedge uut.u_rx.uart_clk); 
            $display("\n------------------------------");
            $display("%-12s %-12s", "TX State   ", "| RX State");
            $display("------------------------------");            
            $display(" %-12b  | %-12b", uut.u_tx.state, uut.u_rx.state);
            $display("------------------------------");

            @(posedge done_rx);           // Waits for the reception to complete (donerx goes high).

            // Print data in table format
//            $display(" %-12h  | %-12h  | %-12b  | %-12b", dintx, doutrx, dut.utx.state, dut.urx.state);
            $display("\n------------------------------");
            $display("%-12s %-12s", "Transmitted", "| Received");
            $display("------------------------------");
            $display(" %-12h  | %-12h", din_tx, dout_rx);
            $display("------------------------------");    
        end
        $finish;           
    end

endmodule
