`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/19 21:36:22
// Design Name: 
// Module Name: wb
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


module wb(
    input WB_valid,
    input [69:0] MEM_WB_bus_r,
    output rf_wen,
    output [4:0] rf_wdest,
    output [31:0] rf_wdata,
    output WB_over,
    output [31:0] WB_pc,
    
    output [31:0] wdt

);

    wire wen;
    wire [4:0] wdest;
    wire [31:0] mem_result;
    wire [31:0] pc;
    assign {wen,wdest,mem_result,pc} = MEM_WB_bus_r;

    assign WB_over = WB_valid;
    assign rf_wen = wen & WB_valid;
    assign rf_wdest = wdest;
    assign rf_wdata = mem_result;
    
    assign wdt = mem_result;

    assign WB_pc = pc;

endmodule