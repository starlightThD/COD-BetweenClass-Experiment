`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/12 15:30:00
// Design Name: 
// Module Name: NPC
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
`define NPC_PLUS4   3'b000
`define NPC_BRANCH  3'b001
`define NPC_JUMP    3'b010
`define NPC_JALR	3'b100

module NPC(
    input [31:0]PC,
    input [2:0]NPCOp,
    input [31:0] RD1,
    input [31:0] dest,
    output reg [31:0]PC_out
    );
    always@(*)begin
        case(NPCOp)
            `NPC_PLUS4:PC_out = PC + 4;
            `NPC_BRANCH:PC_out = PC + dest;
            `NPC_JUMP:PC_out = PC + dest;
            `NPC_JALR:PC_out =RD1 + dest;
            default:PC_out = PC+4;
        endcase
    end
    
endmodule
