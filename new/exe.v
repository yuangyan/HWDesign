`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/19 21:34:48
// Design Name: 
// Module Name: exe
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

module exe(
    input EXE_valid,
    input [149:0] ID_EXE_bus_r,
    output EXE_over,
    output [105:0] EXE_MEM_bus,
    output [31:0] EXE_pc
);
    wire [11:0] alu_control;
    wire [31:0] alu_operand1;
    wire [31:0] alu_operand2;

    wire [3:0] mem_control;
    wire [31:0] store_data;

    wire rf_wen;
    wire [4:0] rf_wdest;
    wire [31:0] pc;
    assign {
        alu_control,
        alu_operand1,
        alu_operand2,
        mem_control,
        store_data,
        rf_wen,
        rf_wdest,
        pc
    } = ID_EXE_bus_r;

    wire [31:0] alu_result;

    alu alu_module (
        .alu_control (alu_control),
        .alu_src1 (alu_operand1),
        .alu_src2 (alu_operand2),
        .alu_result (alu_result)
    );

    assign EXE_over = EXE_valid;
    assign EXE_MEM_bus = {
        mem_control,
        store_data,
        alu_result,
        rf_wen,
        rf_wdest,
        pc
    };
    assign EXE_pc = pc;

endmodule
