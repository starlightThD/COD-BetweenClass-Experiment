`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/10 08:10:10
// Design Name: 
// Module Name: guess_number
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module guess_number(
    input clk,
    input rstn,
    input[15:0]sw_i,
    output[15:0]led_o
    );
    reg ledstate;//led state

    always@(*)
    begin
        if(sw_i[4:1] == 4'b1010) //guess number is 1010
        begin
            ledstate = 1'b1;
        end
        else
        begin
            ledstate = 1'b0;
        end
    end
    assign led_o[15] = ledstate; //led output
endmodule
