`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 08:43:34
// Design Name: 
// Module Name: SCPU_TOP
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
////////////////////////////////////////////////////////////''//////////////////////

module SCPU_TOP(
    input clk,
    input rstn,
    input [15:0]sw_i,
    output [7:0]disp_an_o,
    output [7:0]disp_seg_o    
);
reg [31:0]clkdiv;
wire Clk_CPU;
wire RegWrite;
wire [3:0]rd;
wire [31:0]WD;
assign RegWrite = sw_i[3];
assign rd = sw_i[11:8];
assign WD = 32'h3f3f3f3f;
always@(posedge clk or negedge rstn)
begin
    if(!rstn)
        clkdiv<=0;
    else
        clkdiv<=clkdiv+1'b1;
end
assign Clk_CPU=(sw_i[15])?clkdiv[27]:clkdiv[25];
reg [63:0]display_data;
reg [5:0]led_data_addr;
reg [63:0]led_disp_data;
parameter LED_DATA_NUM=19;
reg [63:0]LED_DATA[18:0];
parameter ROM_DATA_NUM=11;
reg [3:0]rom_addr;
reg [4:0]reg_addr;
initial begin
    LED_DATA[0] = 64'hC6F6F6F0C6F6F6F0;
    LED_DATA[1] = 64'hF9F6F6CFF9F6F6CF;
    LED_DATA[2] = 64'hFFC6F0FFFFC6F0FF;
    LED_DATA[3] = 64'hFFC0FFFFFFC0FFFF;
    LED_DATA[4] = 64'hFFA3FFFFFFA3FFFF;
    LED_DATA[5] = 64'hFFFFA3FFFFFFA3FF;
    LED_DATA[6] = 64'hFFFF9CFFFFFF9CFF;
    LED_DATA[7] = 64'hFF9EBCFFFF9EBCFF;
    LED_DATA[8] = 64'hFF9CFFFFFF9CFFFF;
    LED_DATA[9] = 64'hFFC0FFFFFFC0FFFF;
    LED_DATA[10] = 64'hFFA3FFFFFFA3FFFF;
    LED_DATA[11] = 64'hFFA7B3FFFFA7B3FF;
    LED_DATA[12] = 64'hFFC6F0FFFFC6F0FF;
    LED_DATA[13] = 64'hF9F6F6CFF9F6F6CF;
    LED_DATA[14] = 64'h9EBEBEBC9EBEBEBC;
    LED_DATA[15] = 64'h2737373327373733;
    LED_DATA[16] = 64'h505454EC505454EC;
    LED_DATA[17] = 64'h744454F8744454F8;
    LED_DATA[18] = 64'h0062080000620800;
end
wire [31:0]instr;
reg [31:0]reg_data=32'h11111111;
reg [31:0]alu_disp_data=32'h22222222;
reg [31:0]dmem_data=32'h33333333;

always@(posedge Clk_CPU or negedge rstn)
begin
    if(!rstn)
    begin
        rom_addr=4'b0;
        led_data_addr=6'd0;
        led_disp_data=64'b1;
    end
    else if(sw_i[0]==1'b1)
    begin
        if(led_data_addr==LED_DATA_NUM)
        begin
            led_data_addr=6'd0;
            led_disp_data=64'b1;
        end
        led_disp_data=LED_DATA[led_data_addr];
        led_data_addr=led_data_addr+1;
    end
    else
    begin
        led_data_addr=led_data_addr;
        if(rom_addr==ROM_DATA_NUM)
            rom_addr=4'b0;
        else
            rom_addr=rom_addr+1'b1;
    end
    if(!rstn)
    begin
        reg_addr = 1'b1;
    end else if(sw_i[13] == 1'b1) begin
        reg_addr = reg_addr + 1'b1;
        reg_data = U_RF.rf[reg_addr];
        
    end
end

always@(sw_i)
begin
    if(sw_i[0]==1'b0)
    begin
        case(sw_i[14:11])
            4'b1000:display_data=instr;
            4'b0100:display_data=reg_data;
            4'b0010:display_data=alu_disp_data;
            4'b0001:display_data=dmem_data;
            default:display_data=instr;
        endcase
    end
    else
    begin
        display_data=led_disp_data;
    end
end
dist_mem_im U_IM(.a(rom_addr),.spo(instr));
RF U_RF(.clk(Clk_CPU),.rst(rstn),.RFWr(RegWrite),.sw_i(sw_i),.A1(rs1),.A2(rs2),.A3(rd),.WD(WD),.RD1(RD1),.RD2(RD2));
seg7x16 u_seg7x16(.clk(clk),.rstn(rstn),.i_data(display_data),.disp_mode(sw_i[0]),.o_seg(disp_seg_o),.o_sel(disp_an_o));
endmodule