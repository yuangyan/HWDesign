`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/19 21:35:46
// Design Name: 
// Module Name: mem
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

module mem(
    input clk,
    input MEM_valid,
    input [105:0] EXE_MEM_bus_r,
    input [31:0] dm_rdata,
    output [31:0] dm_addr,
    output reg[3:0] dm_wen,
    output reg [31:0] dm_wdata,
    output MEM_over,
    output [69:0] MEM_WB_bus,

    output [31:0] MEM_pc

);
    wire [3:0] mem_control;
    wire [31:0] store_data;
    wire [31:0] alu_result;

    wire rf_wen;
    wire [4:0] rf_wdest;
    wire [31:0] pc;
    assign {mem_control,
    store_data,
    alu_result,
    rf_wen,
    rf_wdest,
    pc} = EXE_MEM_bus_r;

    wire inst_load;
    wire inst_store;
    wire ls_word;
    wire lb_sign;
    assign {inst_load, inst_store, ls_word, lb_sign}
    = mem_control;

    assign dm_addr = alu_result;
    always @(*) 
    begin
        if (MEM_valid && inst_store) 
        begin
            // ×èÈûÐÍ£¿
            if (ls_word) begin
                dm_wen <= 4'b1111;
            end
            else begin
                case (dm_addr[1:0])
                    2'b00: dm_wen <= 4'b0001;
                    2'b01: dm_wen <= 4'b0010;
                    2'b10: dm_wen <= 4'b0100;
                    2'b11: dm_wen <= 4'b1000; 
                    default: dm_wen <= 4'b0000;
                endcase
            end
        end
        else begin
            dm_wen <= 4'b0000;
        end
    end

    always @(*) begin
        case (dm_addr[1:0])
            2'b00: dm_wdata <= store_data;
            2'b01: dm_wdata <= {16'd0, store_data[7:0], 8'd0};
            2'b10: dm_wdata <= {8'd0, store_data[7:0], 16'd0};
            2'b11: dm_wdata <= {store_data[7:0], 24'd0}; 
            default: dm_wdata <= store_data;
        endcase
    end

    wire load_sign;
    wire [31:0] load_result;
    assign load_sign = (dm_addr[1:0] == 2'd0) ? dm_rdata[7] :
                       (dm_addr[1:0] == 2'd1) ? dm_rdata[15] :
                       (dm_addr[1:0] == 2'd2) ? dm_rdata[23] : dm_rdata[31];

    assign load_result[7:0] = (dm_addr[1:0] == 2'd0) ? dm_rdata[7:0] :
                              (dm_addr[1:0] == 2'd1) ? dm_rdata[15:8] :
                              (dm_addr[1:0] == 2'd2) ? dm_rdata[23:16] :
                                                       dm_rdata[31:24];
      assign load_result[31:8] = ls_word ? dm_rdata[31:8] : 
                                        {24{lb_sign & load_sign}};  
                                                                       
    reg MEM_valid_r;
//    always @(posedge clk ) begin
//        MEM_valid_r <= MEM_valid;
//    end

    reg [1:0] counter;
    always @(posedge MEM_valid) begin
        counter <= 2'd0;
    end

    always @(posedge clk) begin
        if (counter == 2'd1) begin
            MEM_valid_r <= MEM_valid;
            counter <= 2'd0;
        end

        else begin
            counter <= counter + 2'd1;
            MEM_valid_r = 1'd0;
        end
    end
    
    
    assign MEM_over = inst_load ? MEM_valid_r : MEM_valid;
//    assign MEM_over = MEM_valid;
    
    wire [31:0] mem_result;
    assign mem_result = inst_load ? load_result : alu_result;

    assign MEM_WB_bus = {rf_wen, rf_wdest, mem_result, pc};
    assign MEM_pc = pc;
endmodule