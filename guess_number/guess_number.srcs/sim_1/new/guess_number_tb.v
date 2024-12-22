`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/10 08:48:54
// Design Name: 
// Module Name: guess_number_tb
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


module guess_number_tb();
    reg clk,rstn;
    reg [15:0]sw_i;
    wire [15:0]led_o;
    integer foutput,counter,sw_counter;
    
    guess_number u_guess_number(.clk(clk),.rstn(rstn),.sw_i(sw_i),.led_o(led_o));

    initial begin
        counter = 0;
        sw_counter = 0;
        clk = 1;
        rstn = 1;
        sw_i =16'b0000_0000_0001_0100;
        foutput = $fopen("result.txt");
        #5;
        rstn = 0;
        #20;
        rstn = 1;
    end

    always  
    begin
        #50 clk = ~clk;
        if(clk == 1'b1)
        begin
            case (sw_counter)
            0:sw_i = 16'b0000_0000_0001_0100;
            1:sw_i = 16'b0000_0000_0001_0010;
            2:sw_i = 16'b0000_0000_0001_0000;
            3:sw_i = 16'b0000_0000_0000_1110;
            4:sw_i = 16'b0000_0000_0000_1100;
            5:sw_i = 16'b0000_0000_0000_1010;
            6:sw_i = 16'b0000_0000_0000_1000;
            7:sw_i = 16'b0000_0000_0000_0110;
            8:sw_i = 16'b0000_0000_0000_0100;
            9:sw_i = 16'b0000_0000_0000_0010;
            default:sw_i = 16'b0000_0000_0000_0000;
            endcase
            sw_counter = sw_counter + 1;
            if(sw_counter == 10) sw_counter = 0;

            $fdisplay(foutput,"led_o:\t %b",led_o);
            $display("led_o:\t %b",led_o);
            $display("counter: %h",counter);
            counter = counter + 1;
        end
        else if(counter > 100)begin
            $fclose(foutput);
            $stop;
        end
        else begin
            counter = counter;
        end
    end
endmodule
