`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishang Talsania
// Create Date: 14.12.2025
// Module Name: top
// Description:
// Top-level module integrating UART RX, UART TX, and command parser FSM
// Connects PC serial communication to FPGA LED control
// CLKS_PER_BIT = (clock frequency in Hz) / (baud rate)
// Default: 5208 for 100MHz clock @ 19200 baud
// Implements complete serial command interface with bidirectional communication
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Integrated all three modules with proper signal routing
//////////////////////////////////////////////////////////////////////////////////


module top #(parameter CLKS_PER_BIT = 5208) (
    input clk,
    input rst,
    input uart_rx_pin,
    output uart_tx_pin,
    output [7:0] led
);

    wire [7:0] rx_byte;
    wire rx_dv;
    wire [7:0] tx_byte;
    wire tx_dv;
    wire tx_active;
    wire tx_done;
    
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx_inst (
        .clk(clk),
        .i_rx_serial(uart_rx_pin),
        .o_rx_dv(rx_dv),
        .o_rx_byte(rx_byte)
    );
    
    command_parser cmd_parser_inst (
        .clk(clk),
        .rst(rst),
        .rx_byte(rx_byte),
        .rx_dv(rx_dv),
        .tx_done(tx_done),
        .tx_active(tx_active),
        .tx_byte(tx_byte),
        .tx_dv(tx_dv),
        .leds(led)
    );
    
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx_inst (
        .clk(clk),
        .i_tx_dv(tx_dv),
        .i_tx_byte(tx_byte),
        .o_tx_active(tx_active),
        .o_tx_serial(uart_tx_pin),
        .o_tx_done(tx_done)
    );

endmodule