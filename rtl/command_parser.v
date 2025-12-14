`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishang Talsania
// Create Date: 14.12.2025
// Module Name: command_parser
// Description:
// FSM-based command parser for UART communication
// Receives ASCII commands from uart_rx and controls LEDs
// Commands: 'L'=toggle LED0, '0'=LED0 off, '1'=LED0 on, '2'=LED1 on, 'R'=read LED0 status
// States: IDLE -> DECODE -> EXECUTE -> RESPOND -> WAIT_TX -> IDLE
// Implements metastability handling through uart_rx double-flopping
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Added response capability for 'R' command via uart_tx
//////////////////////////////////////////////////////////////////////////////////


module command_parser (
    input clk,
    input rst,
    input [7:0] rx_byte,
    input rx_dv,
    input tx_done,
    input tx_active,
    output reg [7:0] tx_byte,
    output reg tx_dv,
    output reg [7:0] leds
);

    parameter IDLE = 3'd0;
    parameter DECODE = 3'd1;
    parameter EXECUTE = 3'd2;
    parameter RESPOND = 3'd3;
    parameter WAIT_TX = 3'd4;
    
    reg [2:0] state;
    reg [7:0] cmd_byte;
    reg needs_response;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            leds <= 8'h00;
            tx_dv <= 1'b0;
            tx_byte <= 8'h00;
            cmd_byte <= 8'h00;
            needs_response <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_dv <= 1'b0;
                    if (rx_dv) begin
                        cmd_byte <= rx_byte;
                        state <= DECODE;
                    end
                end
                
                DECODE: begin
                    needs_response <= 1'b0;
                    case (cmd_byte)
                        8'h4C: begin
                            state <= EXECUTE;
                        end
                        8'h30: begin
                            state <= EXECUTE;
                        end
                        8'h31: begin
                            state <= EXECUTE;
                        end
                        8'h32: begin
                            state <= EXECUTE;
                        end
                        8'h52: begin
                            needs_response <= 1'b1;
                            state <= EXECUTE;
                        end
                        default: begin
                            state <= IDLE;
                        end
                    endcase
                end
                
                EXECUTE: begin
                    case (cmd_byte)
                        8'h4C: begin
                            leds[0] <= ~leds[0];
                        end
                        8'h30: begin
                            leds[0] <= 1'b0;
                        end
                        8'h31: begin
                            leds[0] <= 1'b1;
                        end
                        8'h32: begin
                            leds[1] <= 1'b1;
                        end
                        8'h52: begin
                            if (leds[0] == 1'b1)
                                tx_byte <= 8'h31;
                            else
                                tx_byte <= 8'h30;
                        end
                        default: begin
                        end
                    endcase
                    
                    if (needs_response)
                        state <= RESPOND;
                    else
                        state <= IDLE;
                end
                
                RESPOND: begin
                    if (!tx_active) begin
                        tx_dv <= 1'b1;
                        state <= WAIT_TX;
                    end
                end
                
                WAIT_TX: begin
                    tx_dv <= 1'b0;
                    if (tx_done) begin
                        state <= IDLE;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule