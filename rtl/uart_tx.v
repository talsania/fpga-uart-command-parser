`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Krishang Talsania
// 
// Create Date: 10.12.2025 15:45:56
// Design Name: 
// Module Name: uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:  
// UART Transmitter - transmits 8 bits of serial data, one start bit, one stop bit,
// and no parity bit
// when receive is complete, o_tx_dv = 1(HIGH) for one clock cycle
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// CLKS_PER_BIT = (clk frequency in hz)/(baud)
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_tx
    #(parameter CLKS_PER_BIT = 5208) (
    input clk, i_tx_dv, [7:0] i_tx_byte,
    output o_tx_active, o_tx_done, reg o_tx_serial
    );
    parameter s_IDLE = 3'b000;
    parameter s_TX_START_BIT = 3'b001;
    parameter s_TX_DATA_BITS = 3'b010;
    parameter s_TX_STOP_BIT = 3'b011;
    parameter s_CLEANUP = 3'b100;
    reg [2:0] r_main=0;
    reg [7:0] r_clk_count=0;
    reg [2:0] r_bit_index=0;
    reg [7:0] r_tx_data=0;
    reg r_tx_done=0;
    reg r_tx_active=0;
    
    always @(posedge clk)
        begin
            case(r_main)
                s_IDLE:
                    begin
                        o_tx_serial <= 1'b1;
                        r_tx_done <= 1'b0;
                        r_clk_count <= 0;
                        r_bit_index <= 0;
                        
                        if(i_tx_dv == 1'b1)
                            begin
                                r_tx_active <= 1'b1;
                                r_tx_data <= i_tx_byte;
                                r_main <= s_TX_START_BIT;
                            end
                        else
                            r_main <= s_IDLE;
                    end
                
                s_TX_START_BIT:
                    begin
                        o_tx_serial <= 1'b0;
                        
                        if(r_clk_count < CLKS_PER_BIT-1)
                            begin
                                r_clk_count <= r_clk_count+1;
                                r_main <= s_TX_START_BIT;
                            end
                        else
                            begin
                                r_clk_count <= 0;
                                r_main <= s_TX_DATA_BITS;
                            end
                        end
                    
                s_TX_DATA_BITS:
                    begin
                        o_tx_serial <= r_tx_data[r_bit_index];
                        
                        if(r_clk_count < CLKS_PER_BIT-1)
                            begin
                                r_clk_count <= r_clk_count+1;
                                r_main <= s_TX_DATA_BITS;
                            end
                        else
                            begin
                                r_clk_count <= 0;
                                
                                if(r_bit_index < 7)
                                    begin
                                        r_bit_index <= r_bit_index+1;
                                        r_main <= s_TX_DATA_BITS;
                                    end
                                else
                                    begin
                                        r_bit_index <= 0;
                                        r_main <= s_TX_STOP_BIT;
                                    end
                            end
                    end
                                
                s_TX_STOP_BIT:
                    begin
                        o_tx_serial <= 1'b1;
                        
                        if(r_clk_count < CLKS_PER_BIT-1)
                            begin
                                r_clk_count <= r_clk_count+1;
                                r_main <= s_TX_STOP_BIT;
                            end
                        else
                            begin
                                r_tx_done <= 1'b1;
                                r_clk_count <= 0;
                                r_main <= s_CLEANUP;
                                r_tx_active <= 1'b0;
                            end
                    end
                                
                s_CLEANUP:
                    begin
                        r_tx_done <= 1'b1;
                        r_main <= s_IDLE;
                    end
                
                default:
                    r_main <= s_IDLE;
                    
            endcase
        end
                    
    assign o_tx_active=r_tx_active;
    assign o_tx_done=r_tx_done;

endmodule
