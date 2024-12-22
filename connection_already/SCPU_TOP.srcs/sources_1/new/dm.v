`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/11 22:21:46
// Design Name: 
// Module Name: dm
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
`define dm_word 3'b000
`define dm_halfword 3'b001
`define dm_halfword_unsigned 3'b010
`define dm_byte 3'b011
`define dm_byte_unsigned 3'b100

module dm(
    input clk,
    input rstn,
    input DMWr,
    input [5:0] addr,
    input [31:0] din,
    input [1:0] DMType,
    output reg [31:0] dout
    );
    reg [7:0] dmem[127:0];
    integer i;
    initial begin
        for(i = 0; i < 127; i = i + 1) begin
            dmem[i] = 0;
        end
    end
    always@(negedge clk) begin
        if(DMWr == 1'b1)begin
            case(DMType)
                `dm_byte: begin
                    dmem[addr] <= din[7:0];
                    dmem[addr+1] <= {8{din[7]}};
                    dmem[addr+2] <= {8{din[7]}};
                    dmem[addr+3] <= {8{din[7]}};
                    end
                `dm_byte_unsigned: dmem[addr] <= din[7:0];
                `dm_halfword: begin
                    dmem[addr]<=din[7:0];
                    dmem[addr+1]<=din[15:8];
                    dmem[addr+2] <= {8{din[15]}};
                    dmem[addr+3] <= {8{din[15]}};
                end
                `dm_halfword_unsigned: begin
                    dmem[addr]<=din[7:0];
                    dmem[addr+1]<=din[15:8];
                end
                `dm_word: begin
                    dmem[addr]<=din[7:0];
                    dmem[addr+1]<=din[15:8];
                    dmem[addr+2]<=din[23:16];
                    dmem[addr+3]<=din[31:24];
                end
            endcase
        end
    case (DMType)
        `dm_byte: dout <= {{24{dmem[addr][7]}},dmem[addr][7:0]};
        `dm_byte_unsigned: dout <= {{24'b0},dmem[addr][7:0]};
        `dm_halfword: dout <= {{16{dmem[addr+1][7]}},dmem[addr+1][7:0],dmem[addr][7:0]};
        `dm_halfword_unsigned: dout <= {{16'b0},dmem[addr+1][7:0],dmem[addr][7:0]};
        `dm_word: dout <= {dmem[addr+3][7:0],dmem[addr+2][7:0],dmem[addr+1][7:0],dmem[addr][7:0]};
        default: dout <= 32'h0;
    endcase
    end


endmodule
