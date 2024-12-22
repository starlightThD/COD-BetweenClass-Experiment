`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/10 08:21:20
// Design Name: 
// Module Name: stimulate
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


module stimulate();
    reg clk,rstn;
    reg [15:0]sw_i;
    wire [15:0]led_o;
    integer foutput,counter;

    guess_number dut(.clk(clk),.rstn(rstn),.sw_i(sw_i),.led_o(led_o));
    initial begin
        counter = 0;
        clk = 1;
        rstn = 1;
        sw_i = 16'b0000_0000_0001_0100;
        foutput = $fopen("output.txt","w");
        #5;
        rstn = 0;
        #20;
        rstn = 1;
    end

    always @(*) begin
        #50 clk = ~clk;
        if(clk == 1'b1)begin
            $fdisplay(foutput,"led_o:\t %b",led_o);
            $display("led_o:\t %b",led_o);
            $display("counter: %h",counter);
            counter = counter + 1;
        end
        else if(counter > 100)begin
            $fclose(foutput);
            $stop;end
            else begin
                counter = counter;
            end
        
    end
endmodule
