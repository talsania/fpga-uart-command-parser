`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishang Talsania
// Create Date: 14.12.2025
// Module Name: command_parser_tb
// Description:
// Testbench for command parser integrated system
// Tests all command types: '0', '1', 'L', '2' and verifies LED control
// Uses 10MHz clock and 115200 baud UART timing
// CLKS_PER_BIT = 10000000 / 115200 = 87
// Includes UART_WRITE task to simulate serial transmission from PC
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Added comprehensive test cases for all commands
//////////////////////////////////////////////////////////////////////////////////


module command_parser_tb();
    parameter c_CLK_PERIOD = 100;
    parameter c_CLKS_PER_BIT = 87;
    parameter c_BIT_PERIOD = 8600;
    
    reg r_clk = 0;
    reg r_rst = 0;
    reg r_rx_serial = 1;
    wire [7:0] w_led;
    wire w_tx_serial;
    
    task UART_WRITE;
        input [7:0] i_data;
        integer x;
        begin
            r_rx_serial <= 1'b0;
            #(c_BIT_PERIOD);
            
            for (x=0; x<8; x=x+1) begin
                r_rx_serial <= i_data[x];
                #(c_BIT_PERIOD);
            end
            
            r_rx_serial <= 1'b1;
            #(c_BIT_PERIOD);
        end
    endtask
    
    top #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) top_inst (
        .clk(r_clk),
        .rst(r_rst),
        .uart_rx_pin(r_rx_serial),
        .uart_tx_pin(w_tx_serial),
        .led(w_led)
    );
    
    always #(c_CLK_PERIOD/2) r_clk <= !r_clk;
    
    initial begin
        r_rst = 1;
        #200;
        r_rst = 0;
        #5000;
        
        $display("Test 1: Send '1' - LED[0] should turn ON");
        UART_WRITE(8'h31);
        #50000;
        if (w_led[0] == 1'b1)
            $display("PASS: LED[0] = 1");
        else
            $display("FAIL: LED[0] = %b", w_led[0]);
        
        $display("Test 2: Send '0' - LED[0] should turn OFF");
        UART_WRITE(8'h30);
        #50000;
        if (w_led[0] == 1'b0)
            $display("PASS: LED[0] = 0");
        else
            $display("FAIL: LED[0] = %b", w_led[0]);
        
        $display("Test 3: Send 'L' - LED[0] should TOGGLE");
        UART_WRITE(8'h4C);
        #50000;
        if (w_led[0] == 1'b1)
            $display("PASS: LED[0] toggled to 1");
        else
            $display("FAIL: LED[0] = %b", w_led[0]);
        
        $display("Test 4: Send 'L' again - LED[0] should TOGGLE back");
        UART_WRITE(8'h4C);
        #50000;
        if (w_led[0] == 1'b0)
            $display("PASS: LED[0] toggled to 0");
        else
            $display("FAIL: LED[0] = %b", w_led[0]);
        
        $display("Test 5: Send '2' - LED[1] should turn ON");
        UART_WRITE(8'h32);
        #50000;
        if (w_led[1] == 1'b1)
            $display("PASS: LED[1] = 1");
        else
            $display("FAIL: LED[1] = %b", w_led[1]);
        
        $display("All tests complete");
        #5000;
        $finish;
    end

endmodule