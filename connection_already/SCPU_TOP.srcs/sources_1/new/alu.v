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
`define ALUOp_nop 5'b00000
`define ALUOp_lui 5'b00001
`define ALUOp_auipc 5'b00010
`define ALUOp_add 5'b00011
`define ALUOp_sub 5'b00100
`define ALUOp_bne 5'b00101
`define ALUOp_blt 5'b00110
`define ALUOp_bge 5'b00111
`define ALUOp_bltu 5'b01000
`define ALUOp_bgeu 5'b01001
`define ALUOp_slt 5'b01010
`define ALUOp_sltu 5'b01011
`define ALUOp_xor 5'b01100
`define ALUOp_or 5'b01101
`define ALUOp_and 5'b01110
`define ALUOp_sll 5'b01111
`define ALUOp_srl 5'b10000
`define ALUOp_sra 5'b10001
`define ALUOp_beq 5'b10010
 
module alu(
    input signed [31:0] A,B,
    input [4:0] ALUOp,
    output reg signed [31:0] C,
    output reg Zero
    );
    always @(*) begin
        case(ALUOp)
            `ALUOp_nop: C = 32'h00000000;
            `ALUOp_add: C = A + B;
            `ALUOp_sub: C = A - B;
            `ALUOp_bne: C = (A != B) ? 32'h00000000 : 32'h00000001;
            `ALUOp_blt: C = (A  < B) ? 32'h00000000 : 32'h00000001;
            `ALUOp_bge: C = (A  >= B) ? 32'h00000000 : 32'h00000001;
            `ALUOp_bltu: C = ($unsigned(A) <$unsigned(B)) ? 32'h00000000 : 32'h00000001;
            `ALUOp_bgeu: C = ($unsigned(A) >= $unsigned(B)) ? 32'h00000000 : 32'h00000001;
            `ALUOp_slt: C = (A < B) ? 32'h00000000 : 32'h00000001;
            `ALUOp_sltu: C = ($unsigned(A) < $unsigned(B)) ? 32'h00000000 : 32'h00000001;
            `ALUOp_xor: C = A ^ B;
            `ALUOp_or: C = A | B;
            `ALUOp_and: C = A & B;
            `ALUOp_sll: C = A << B[4:0];
            `ALUOp_srl: C = A >> B[4:0];
            `ALUOp_sra: C = $signed(A) >>> B[4:0];
            `ALUOp_beq: C = (A == B) ? 32'h00000000 : 32'h00000001;
            default: C = 32'hFFFFFFFF;
        endcase
        Zero = (C == 0? 1'b1 : 1'b0);
    end
    
endmodule
