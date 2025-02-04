`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 00:13:18
// Design Name: 
// Module Name: sccomp
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


module sccomp(clk,rstn,sw_i,disp_seg_o,disp_an_o);
    input clk;
    input rstn;
    inout [15:0] sw_i;
    output [7:0] disp_an_o,disp_seg_o;  // 8-bit output to display 7-segment display
    reg[31:0]clkdiv;
    wire clk_CPU;

    always@(posedge clk or negedge rstn) begin
        if(!rstn) clkdiv <= 0;
        else clkdiv <= clkdiv+ 1'b1;
    end

    assign clk_CPU = (sw_i[15]) ? clkdiv[27] : clkdiv[25];

    reg[63:0] display_data;

    reg [2:0]led_data_addr;
    reg[63:0]led_disp_data;
    parameter LED_DATA_NUM = 8;

    reg [63:0]LED_DATA[8:0];// register array to store LED data
    initial begin
        LED_DATA[0] = 64'hC6F6F6F0C6F6F6F0;
        LED_DATA[1] = 64'hF9F6F6CFF9F6F6CF;
        LED_DATA[2] = 64'hFFC6F0FFFFC6F0FF;
        LED_DATA[3] = 64'hFFC0FFFFFFC0FFFF;
        LED_DATA[4] = 64'hFFA3FFFFFFA3FFFF;
        LED_DATA[5] = 64'hFFFFA3FFFFFFA3FF;
        LED_DATA[6] = 64'hFFFF9CFFFFFF9CFF;
        LED_DATA[7] = 64'hFF9EBCFFFF9EBCFF;
        // LED_DATA[8] = 64'hFF9CFFFFFF9CFFFF;
        // LED_DATA[9] = 64'hFFC0FFFFFFC0FFFF;
        // LED_DATA[10] = 64'hFFA3FFFFFFA3FFFF;
        // LED_DATA[11] = 64'hFFA7B3FFFFA7B3FF;
        // LED_DATA[12] = 64'hFFC6F0FFFFC6F0FF;
        // LED_DATA[13] = 64'hF9F6F6CFF9F6F6CF;
        // LED_DATA[14] = 64'h9EBEBEBC9EBEBEBC;
        // LED_DATA[15] = 64'h2737373327373733;
        // LED_DATA[16] = 64'h505454EC505454EC;
        // LED_DATA[17] = 64'h744454F8744454F8;
        // LED_DATA[18] = 64'h0062080000620800;
    end
    always@(posedge clk_CPU or negedge rstn) begin
        if(!rstn) begin
            led_data_addr = 6'd0;
            led_disp_data = 64'b1;
        end
        else if(sw_i[0] == 1'b1)begin
            if(led_data_addr == LED_DATA_NUM)begin
                led_data_addr = 6'd0;
                led_disp_data = 64'b1;
            end
            led_disp_data = LED_DATA[led_data_addr];
            led_data_addr = led_data_addr + 1'b1;
        end
        else led_data_addr = led_data_addr;
        end
wire [31:0] instr;
reg[31:0] reg_data;
reg[31:0] alu_disp_data;
reg[31:0] dmemdata;

        always@(sw_i) begin
            if(sw_i[0] == 0)begin
                case (sw_i[14:11])
                    4'b1000: display_data = instr;
                    4'b0100: display_data = reg_data;
                    4'b0010: display_data = alu_disp_data;
                    4'b0001: display_data = dmemdata;
                    default: display_data = instr;
                endcase
            end
            else begin
                display_data = led_disp_data;
            end
        end

        seg7x16 u_seg7x16(
            .clk(clk),
            .rstn(rstn),
            .i_data(display_data),
            .disp_mode(sw_i[0]),
            .o_seg(disp_seg_o),
            .o_sel(disp_an_o)
        );
endmodule
