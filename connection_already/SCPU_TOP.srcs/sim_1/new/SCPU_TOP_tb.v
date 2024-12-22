`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/24 10:00:00
// Design Name: 
// Module Name: SCPU_TOP_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Testbench for SCPU_TOP module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SCPU_TOP_tb();
    // Declare inputs as regs
    reg clk;
    reg rstn;
    reg [15:0] sw_i; // sw_i should be 16 bits

    // Declare outputs as wires
    wire [7:0] disp_an_o;
    wire [7:0] disp_seg_o;

    // Instantiate the Device Under Test (DUT)
    SCPU_TOP U_SCPU_TOP(
        .clk(clk),
        .rstn(rstn),
        .sw_i(sw_i),
        .disp_an_o(disp_an_o),
        .disp_seg_o(disp_seg_o)
    );

    // Clock generation: Period is 2ns, toggles every 1ns
    initial begin
        clk = 0;
        forever #1 clk = ~clk; // 1ns high, 1ns low for 2ns period
    end

    // Input stimulus generation
    initial begin
        // Initialize inputs
        rstn = 0; // Initial reset
        sw_i = 16'b0; // Initial value for sw_i

        // Apply reset
        #5 rstn = 1;  // Set rstn high after 5ns
        #15 rstn = 0; // Set rstn low after another 15ns (total 20ns)
        #1 rstn = 1;  // Set rstn high again to deactivate reset

        // Stimulate sw_i
        #5 sw_i = 16'b0000_0000_0000_0001; // After activating rstn, set sw_i to some value
        #20 sw_i = 16'b0000_0000_0000_0000; // Clear sw_i to zero
        
        // Continue for a certain duration before finishing the simulation
        #100 $finish; // End the simulation after 100ns
    end
endmodule
