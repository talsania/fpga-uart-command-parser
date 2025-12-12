`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Krishang Talsania
// 
// Create Date: 10.12.2025 14:46:23
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// UART Receiver - receives 8 bits of serial data, one start bit, one stop bit,
// and no parity bit
// when receive is complete, o_rx_dv = 1(HIGH) for one clock cycle
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// CLKS_PER_BIT = (clk frequency in hz)/(baud)
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx
    #(parameter CLKS_PER_BIT = 5208) (
    input clk, i_rx_serial,
    output o_rx_dv, [7:0] o_rx_byte
    );
    parameter s_IDLE = 3'b000;
    parameter s_RX_START_BIT = 3'b001;
    parameter s_RX_DATA_BITS = 3'b010;
    parameter s_RX_STOP_BIT = 3'b011;
    parameter s_CLEANUP = 3'b100;
    reg r_rx_data_r=1'b1;
    reg r_rx_data=1'b1;
    reg [7:0] r_clk_count=0;
    reg [2:0] r_bit_index=0;
    reg [7:0] r_rx_byte=0;
    reg r_rx_dv=0;
    reg [2:0] r_main=0;
    
    // double register
    always @(posedge clk)
        begin
            r_rx_data_r <= i_rx_serial;
            r_rx_data <= r_rx_data_r;
        end
    
    // control rx state machine
    always @(posedge clk)
        begin
        
            case(r_main)
                s_IDLE:
                    begin
                        r_rx_dv <= 1'b0;
                        r_clk_count <= 0;
                        r_bit_index <= 0;
                        
                        // detect start bit
                        if(r_rx_data == 1'b0)
                            r_main <= s_RX_START_BIT;
                        else
                            r_main <= s_IDLE;
                    end
                
                // check middle of start bit
                s_RX_START_BIT:
                    begin
                        if(r_clk_count == (CLKS_PER_BIT-1)/2)
                            begin
                                if(r_rx_data == 1'b0)
                                    begin
                                        r_clk_count <= 0;
                                        r_main <= s_RX_DATA_BITS;
                                    end
                                else
                                    r_main <= s_IDLE;
                                end
                            else
                                begin
                                    r_clk_count <= r_clk_count+1;
                                    r_main <= s_RX_START_BIT;
                                end
                            end
                        
                        // wait one bit duration
                s_RX_DATA_BITS:
                    begin
                        if(r_clk_count < CLKS_PER_BIT-1)
                            begin
                                r_clk_count <= r_clk_count+1;
                                r_main <= s_RX_DATA_BITS;
                            end
                        else
                            begin
                                r_clk_count <= 0;
                                r_rx_byte[r_bit_index] <= r_rx_data;
                        
                            // check if received 8 bits
                            if(r_bit_index < 7)
                                begin
                                    r_bit_index <= r_bit_index+1;
                                    r_main <= s_RX_DATA_BITS;
                                end
                            else
                                begin
                                    r_bit_index <= 0;
                                    r_main <= s_RX_STOP_BIT;
                                end
                        end
                    end
                
                s_RX_STOP_BIT: // =1
                    begin
                        // wait one bit duration
                        if(r_clk_count < CLKS_PER_BIT-1)
                            begin
                                r_clk_count <= r_clk_count+1;
                                r_main <= s_RX_STOP_BIT;
                            end
                        else
                            begin
                                r_rx_dv <= 1'b1;
                                r_clk_count <= 0;
                                r_main <= s_CLEANUP;
                            end
                    end
                
                // 1 clock
                s_CLEANUP:
                    begin
                        r_main <= s_IDLE;
                        r_rx_dv <= 1'b0;
                    end
                
                default:
                    r_main <= s_IDLE;
                
            endcase
        end
    assign o_rx_dv=r_rx_dv;
    assign o_rx_byte=r_rx_byte; 
    
endmodule
