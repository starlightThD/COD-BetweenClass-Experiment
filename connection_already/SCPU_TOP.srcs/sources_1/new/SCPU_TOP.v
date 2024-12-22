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
`define WDSel_FromALU 2'b00  
`define WDSel_FromMEM 2'b01
`define WDSel_FromPC  2'b10 

module SCPU_TOP(
    input clk,
    input rstn,
    input [15:0]sw_i,
    output [7:0]disp_an_o,
    output [7:0]disp_seg_o,
    output [15:0] led_o
);
//Decode
    wire [31:0]instr;
    wire [6:0]Op ;  // op
    wire [6:0]Funct7 ; // funct7
    wire [2:0]Funct3 ; // funct3
    wire [4:0]rs1;  // rs1
    wire [4:0]rs2;  // rs2
    wire [4:0]rd;  // rd
    wire [11:0]iimm;//addi immediate number
    wire [11:0]simm;//sw immediate number
    wire [11:0]bimm;
    wire [19:0] uimm;
    wire [19:0] jimm;
    assign Op = instr[6:0];
    assign Funct7 = instr[31:25];
    assign Funct3 = instr[14:12];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd = instr[11:7];
    assign iimm = instr[31:20];
    assign simm = {instr[31:25],instr[11:7]};
    assign bimm = {instr[31],instr[7],instr[30:25],instr[11:8]};
    assign uimm =instr[31:12];
    assign jimm = {instr[31],instr[19:12],instr[20],instr[30:21]};


// Clock Divider
reg [31:0]clkdiv;
wire Clk_CPU;

always@(posedge clk or negedge rstn)
begin
    if(!rstn)
        clkdiv<=0;
    else
        clkdiv<=clkdiv+1'b1;
end
assign Clk_CPU=(sw_i[15])?clkdiv[26]:clkdiv[24];

reg [63:0]display_data;
reg [5:0]led_data_addr;
reg [63:0]led_disp_data;
parameter LED_DATA_NUM=19;
reg [63:0]LED_DATA[18:0];

//ROM
parameter ROM_DATA_NUM=24;
reg [31:0]rom_addr;

//RF
wire RegWrite;
wire [31:0] RD1;
wire [31:0] RD2;
reg [31:0] WD;
wire [1:0] WDSel;

reg [4:0]reg_addr;//address for register showing

//EXT
wire [5:0] EXTOp;
wire [31:0] immout;

//ALU
reg [2:0] alu_addr;
wire [31:0] A;
wire [31:0] B;
wire [4:0] ALUOp;
wire [31:0] aluout;
wire Zero;
assign A = RD1;
assign B = (ALUSrc) ? immout : RD2;


//DM
wire MemWrite;
wire [5:0] dm_addr;
wire [31:0] dm_din;
wire [2:0] DMType;
wire [31:0] dout;
assign dm_din = RD2;
assign dm_addr = aluout;

//PC
reg [31:0] PC;
wire [2:0]NPCOp;
wire [31:0]dest;
wire [31:0]PC_out;
assign dest = immout;

parameter DM_DATA_NUM = 16;
reg [5:0]dmem_addr=6'b0;//address for showing


initial begin
    PC= 4'b0000;
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

reg [31:0]reg_data=32'h0;
reg [31:0]alu_disp_data=32'h0;
reg [31:0]dmem_data=32'h0;


//SHOW Control
always@(posedge Clk_CPU or negedge rstn)
begin
//ROM
    if(!rstn)
    begin
        case (sw_i[5:2])
            4'b0000:PC <= 32'h0000_0000; //beq
            4'b0001:PC <= 32'h0000_0080; //bne
            4'b0010:PC <= 32'h0000_0100; //blt
            4'b0011:PC <= 32'h0000_0180; //bge
            4'b0100:PC <= 32'h0000_0200; //bltu
            4'b0101:PC <= 32'h0000_0280; //bgeu
            4'b0110:PC <= 32'h0000_0300; //jal
            4'b0111:PC <= 32'h0000_037c; //jalr   
            4'b1000:PC <= 32'h0000_03f0; //sll
            4'b1001:PC <= 32'h0000_0410; //srl 
            4'b1010:PC <= 32'h0000_0430; //sra 
            default: PC<=32'h0000_0000;
        endcase
        rom_addr=32'b0;
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
        if(rom_addr==ROM_DATA_NUM)
            PC = PC;
        else if(sw_i[1] == 1'b0) //pause to show rom
            PC = PC_out;
        rom_addr = PC >> 2;
    end

//RF
    
    if(!rstn)
        reg_addr = 1'b0;
    else if(reg_addr == 5'b10000)
        reg_addr = 1'b0;
    else if(sw_i[13] == 1'b1) begin
        reg_addr = reg_addr + 1'b1;
        reg_data = {3'b000,reg_addr,U_RF.rf[reg_addr][23:0]};
    end

//ALU
    if(!rstn)
    begin
        alu_addr = 3'b0;
    end
    else
    begin
        alu_addr = alu_addr + 1'b1;
        case(alu_addr)
            3'b000:alu_disp_data = U_alu.A;
            3'b001:alu_disp_data = U_alu.B;
            3'b010:alu_disp_data = U_alu.C;
            3'b011:alu_disp_data = U_alu.Zero;
            default:
            begin
            alu_disp_data = 32'hFFFFFFFF;
            alu_addr = 3'b111;
            end
        endcase
    end

    //DM
    if(!rstn)begin
        dmem_addr = 1'b0;
        dmem_data = 1'b0;
    end 
    else if(sw_i[11] == 1'b1) begin
        dmem_addr = dmem_addr + 1'b1;
        dmem_data = {2'b00,dmem_addr,16'b0000_0000_0000_0000,U_DM.dmem[dmem_addr][7:0]};
        if(dmem_addr == DM_DATA_NUM)begin
            dmem_addr = 6'b0;
            dmem_data = 32'hFFFFFFFF;
        end
    end
end

//LED Control 

always@(*) begin
    case(WDSel)
            `WDSel_FromALU: WD <=aluout;
            `WDSel_FromMEM: WD <=dout;
            `WDSel_FromPC:  WD <=PC+4;
    endcase
    if(sw_i[0]==1'b0)
    begin
        case(sw_i[14:11])
            4'b1000:display_data=instr;
            4'b0100:display_data=reg_data;
            4'b0010:display_data=alu_disp_data;
            4'b0001:display_data=dmem_data;
            4'b1010:display_data=PC;
            4'b1001:display_data = immout;
            default: display_data = PC;
        endcase
    end
    else
    begin
        display_data=led_disp_data;
    end    
end

//Example
dist_mem_im U_IM(
    .a(rom_addr),
    .spo(instr));
alu U_alu(
    .A(A),
    .B(B),
    .ALUOp(ALUOp),
    .C(aluout),
    .Zero(Zero));
RF U_RF(
    .clk(Clk_CPU),
    .rst(rstn),
    .RFWr(RegWrite),
    .sw_i(sw_i),
    .A1(rs1),
    .A2(rs2),
    .A3(rd),
    .WD(WD),
    .RD1(RD1),
    .RD2(RD2));
dm U_DM(
    .clk(Clk_CPU),
    .rstn(rstn),
    .DMWr(MemWrite),
    .addr(dm_addr[5:0]),
    .din(dm_din),
    .DMType(DMType[2:0]),
    .dout(dout));
ctrl U_ctrl(
    .Op(Op),
    .Funct7(Funct7),
    .Funct3(Funct3),
    .Zero(Zero),
    .RegWrite(RegWrite),
    .MemWrite(MemWrite),
    .EXTOp(EXTOp),
    .ALUOp(ALUOp),
    .NPCOp(NPCOp),
    .ALUSrc(ALUSrc),
    .DMType(DMType),
    .WDSel(WDSel));
EXT U_EXT(
    .iimm_shamt(iimm_shamt),
    .iimm(iimm),
    .simm(simm),
    .bimm(bimm),
    .uimm(uimm),
    .jimm(jimm),
    .EXTOp(EXTOp),
    .immout(immout));
NPC U_NPC(
    .PC(PC),
    .NPCOp(NPCOp),
    .RD1(RD1),
    .dest(dest),
    .PC_out(PC_out)
);
seg7x16 u_seg7x16(
    .clk(clk),
    .rstn(rstn),
    .i_data(display_data),
    .disp_mode(sw_i[0]),
    .o_seg(disp_seg_o),
    .o_sel(disp_an_o));
    
endmodule