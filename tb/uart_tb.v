`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Krishang Talsania
// 
// Create Date: 10.12.2025 16:50:24
// Design Name: 
// Module Name: uart_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// sends byte 0xAB over tx
// receives byte 0x3F over rx
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// uses 10 MHz clock
// 115200 baud UART
// 10000000 / 115200 = 87 CLKS_PER_BIT
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tb();
    parameter c_CLK_PERIOD=100; // 10MHz
    parameter c_CLKS_PER_BIT=87; // baud 115200
    parameter c_BIT_PERIOD=8600;
    reg r_clk=0;
    reg r_tx_dv=0;
    wire w_tx_done;
    reg [7:0] r_tx_byte=0;
    reg r_rx_serial=1;
    wire [7:0] w_rx_byte;
    
    task UART_WRITE;
        input [7:0] i_data;
        integer x;
        begin
            
            r_rx_serial <= 1'b0;
            #(c_BIT_PERIOD);
            #1000;
            
            for (x=0; x<8; x=x+1)
                begin
                    r_rx_serial <= i_data[x];
                    #(c_BIT_PERIOD);
                end
                
            r_rx_serial <= 1'b1;
            #(c_BIT_PERIOD);
        end
    endtask
    
    uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT))
    UART_RX_INST (
    .clk(r_clk), .i_rx_serial(r_rx_serial), 
    .o_rx_dv(), .o_rx_byte(w_rx_byte)
    );
    
    uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT))
    UART_TX_INST (
    .clk(r_clk), .i_tx_dv(r_tx_dv), .i_tx_byte(r_tx_byte), 
    .o_tx_active(), .o_tx_serial(), .o_tx_done(w_tx_done)
    );
    
    always #(c_CLK_PERIOD/2) r_clk<=!r_clk;
    
    // main
    initial
        begin
            // tx
            @(posedge r_clk);
            @(posedge r_clk);
            r_tx_dv<=1'b1;
            r_tx_byte<=8'hAB;
            @(posedge r_clk);
            r_tx_dv<=1'b0;
            @(posedge w_tx_done);
            // rx
            @(posedge r_clk);
            UART_WRITE(8'h3F);
            @(posedge r_clk);
            // check
            if(w_rx_byte==8'h3F) $display("PASS");
            else $display("FAIL");
            $display($time); $finish;
        end
endmodule