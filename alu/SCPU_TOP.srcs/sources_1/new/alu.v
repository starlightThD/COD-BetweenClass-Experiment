`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/08 08:04:42
// Design Name: 
// Module Name: alu
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
//ALU control codes
`define ALUOp_add 5'b00001
`define ALUOp_sub 5'b00010

module alu(
    input signed [31:0] A,B,
    input [4:0] ALUOp,
    output reg signed [31:0] C,
    output reg Zero
    );
    always @(*) begin
        case(ALUOp)
            `ALUOp_add: C = A + B;
            `ALUOp_sub: C = A - B;
        endcase
        Zero = (C == 0? 1'b1 : 1'b0);
    end
    
endmodule
