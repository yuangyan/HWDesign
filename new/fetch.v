`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/19 21:29:35
// Design Name: 
// Module Name: fetch
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

`define STARTADDR 32'd0
module fetch(
    input clk,
    input resetn,
    input IF_valid,     //active low
    input next_fetch,   //signal to fetch
    input [31:0] inst,  
    input [32:0] jbr_bus,
    output [31:0] inst_addr,
    output reg IF_over,
    output [63:0] IF_ID_bus,
    // for display
    output [31:0] IF_pc,
    output [31:0] IF_inst,
    
    output [31:0] next_pc1,
    output [31:0] seq_pc1

);

    // PC
    wire [31:0] next_pc;
    wire [31:0] seq_pc;     
    reg [31:0] pc;
    
    wire jbr_taken;
    wire [31:0] jbr_target;
    
    reg IF_over0;

    assign {jbr_taken, jbr_target} = jbr_bus;
    assign seq_pc [31:2] = pc[31:2] + 1'b1;
    assign seq_pc[1:0] = pc[1:0];
    assign next_pc = jbr_taken ? jbr_target : seq_pc;

    always @(posedge clk)
    begin
        if (! resetn)
        begin
            pc <= `STARTADDR;
        end
        else if (next_fetch)
        begin
            pc <= next_pc;
        end
    end

    assign inst_addr = pc;
    reg [1:0] counter;
    
    always @(posedge IF_valid) 
    begin
            counter <= 2'd0;
    end
    
    always @(posedge clk) begin
        
        if (counter == 2'd1)begin
      
            IF_over <= 1'b1 & IF_valid;
            counter <= 2'd0;
        end
        else begin
            counter <= counter + 2'd1;
            IF_over <= 1'b0;
        end
  
        
    end


//    always @(posedge clk) 
//    begin
//        IF_over <= IF_valid;
//    end
    
    
    assign IF_ID_bus = {pc, inst};
    assign IF_pc = pc;
    assign IF_inst = inst;
    
    assign next_pc1 = next_pc;
    assign seq_pc1 = seq_pc;

endmodule
