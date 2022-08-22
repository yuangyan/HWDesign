`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/08/19 21:37:29
// Design Name: 
// Module Name: multi_cycle_cpu
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


module multi_cycle_cpu (
    input clk,
    input resetn,
//    input [4:0] rf_addr,
//    input [31:0] mem_addr,
    output [31:0] rf_data,
    output [31:0] mem_data,
    output [31:0] IF_pc,
    output [31:0] IF_inst,
    output [31:0] ID_pc,
    output [31:0] EXE_pc,
    output [31:0] MEM_pc,
    output [31:0] WB_pc,
    output [31:0] display_state,
    
    output IF_over1,
    output ID_over1,
    output EXE_over1,
    output MEM_over1,
    output WB_over1,
    output IF_valid1,
    output [31:0] wdt,
    
    output [31:0] next_pc1,
    output [31:0] seq_pc1,
    output next_fetch1,
    
    output [4:0] rf_addr,
    output rf_wen1,
    output [31:0] mem_addr,
    output [3:0] dm_wen1
    
    
    
    );
    
    reg [2:0] state;
    reg [2:0] next_state;
    assign display_state = {29'd0, state};
    parameter IDLE = 3'd0;
    parameter FETCH = 3'd1; 
    parameter DECODE = 3'd2; 
    parameter EXE = 3'd3; 
    parameter MEM = 3'd4; 
    parameter WB = 3'd5; 
    
    
    always @(posedge clk ) begin
        if (! resetn) begin
            state <= IDLE;        
        end 
        else begin
            state <= next_state; 
        end
    end

    wire IF_over;
    wire ID_over;
    wire EXE_over;
    wire MEM_over;
    wire WB_over;
    wire jbr_not_link;
    
    assign IF_over1 = IF_over;
    assign ID_over1 = ID_over;
    assign MEM_over1 = MEM_over;
    assign EXE_over1 = EXE_over;
    assign WB_over1 = WB_over;


    always @(*) begin
        case (state)
            IDLE: next_state = FETCH;
            FETCH: next_state = IF_over ? DECODE : FETCH;

            DECODE: next_state = ID_over ? 
                                 (jbr_not_link ? FETCH : EXE) : DECODE;
            EXE: next_state = EXE_over ? MEM : EXE;
            MEM: next_state = MEM_over ? WB : MEM;
            WB: next_state = WB_over ? FETCH : WB;
            default: next_state = IDLE;
        endcase
    end

    wire IF_valid;
    wire ID_valid;
    wire EXE_valid;
    wire MEM_valid;
    wire WB_valid;
    assign IF_valid = (state == FETCH ); 
    assign ID_valid = (state == DECODE); 
    assign EXE_valid = (state == EXE ); 
    assign MEM_valid = (state == MEM ); 
    assign WB_valid = (state == WB ); 
    
    assign IF_valid1 = IF_valid;

    wire [ 63:0] IF_ID_bus; 
    wire [149:0] ID_EXE_bus;
    wire [105:0] EXE_MEM_bus;
    wire [ 69:0] MEM_WB_bus;

    reg [ 63:0] IF_ID_bus_r;
    reg [149:0] ID_EXE_bus_r;
    reg [105:0] EXE_MEM_bus_r;
    reg [ 69:0] MEM_WB_bus_r;

    always @(posedge clk ) begin
        if (IF_over)    IF_ID_bus_r <= IF_ID_bus;
        if (ID_over)    ID_EXE_bus_r <= ID_EXE_bus;
        if (EXE_over)   EXE_MEM_bus_r <= EXE_MEM_bus;
        if (MEM_over)   MEM_WB_bus_r <= MEM_WB_bus;
    end

    wire [ 32:0] jbr_bus;
    wire [31:0] inst_addr;
    wire [31:0] inst;

    wire [ 3:0] dm_wen;
    assign dm_wen1 = dm_wen;
    wire [31:0] dm_addr;
    wire [31:0] dm_wdata;
    wire [31:0] dm_rdata;
    
    assign mem_addr = dm_addr;

    wire [ 4:0] rs;
    wire [ 4:0] rt;
    wire [31:0] rs_value;
    wire [31:0] rt_value;

    wire rf_wen;
    assign rf_wen1 = rf_wen;
    wire [ 4:0] rf_wdest;
    wire [31:0] rf_wdata;
    
    assign rf_addr = rf_wdest;
    wire next_fetch;
    assign next_fetch = (state==DECODE & ID_over & jbr_not_link) 
                | (state==WB & WB_over);
    assign next_fetch1 = next_fetch;
    
    fetch IF_module (
        .clk (clk),
        .resetn (resetn),
        .IF_valid (IF_valid),
        .next_fetch (next_fetch),
        .inst (inst),
        .jbr_bus (jbr_bus),
        .inst_addr (inst_addr),
        .IF_over (IF_over),
        .IF_ID_bus (IF_ID_bus),

        .IF_pc (IF_pc),
        .IF_inst (IF_inst),
        
        .next_pc1 (next_pc1),
        .seq_pc1 (seq_pc1)
       
    );

    decode ID_module(
        .ID_valid (ID_valid),
        .IF_ID_bus_r (IF_ID_bus_r),
        .rs_value (rs_value),
        .rt_value (rt_value),
        .rs (rs),
        .rt (rt),
        .jbr_bus (jbr_bus),
        .jbr_not_link (jbr_not_link),
        .ID_over (ID_over),
        .ID_EXE_bus (ID_EXE_bus),

        .ID_pc (ID_pc)
    );

    exe EXE_module(
        .EXE_valid (EXE_valid),
        .ID_EXE_bus_r (ID_EXE_bus_r),
        .EXE_over (EXE_over),
        .EXE_MEM_bus (EXE_MEM_bus),

        .EXE_pc (EXE_pc)
    );

    mem MEM_module(
        .clk (clk),
        .MEM_valid (MEM_valid),
        .EXE_MEM_bus_r (EXE_MEM_bus_r),
        .dm_rdata (dm_rdata),
        .dm_addr (dm_addr),
        .dm_wen (dm_wen),
        .dm_wdata (dm_wdata),
        .MEM_over (MEM_over),
        .MEM_WB_bus (MEM_WB_bus),

        .MEM_pc (MEM_pc)
        
    );

    wb WB_module(
        .WB_valid (WB_valid),
        .MEM_WB_bus_r (MEM_WB_bus_r),
        .rf_wen (rf_wen),
        .rf_wdest (rf_wdest),
        .rf_wdata (rf_wdata),
        .WB_over (WB_over),
        .WB_pc (WB_pc),
        .wdt (wdt)
    );
    
    inst_rom inst_rom_module(
        .clka (clk),
        .addra (inst_addr[9:2]),
        .douta (inst)
    );

    regfile rf_module(
        .clk (clk),
        .wen (rf_wen),
        .raddr1 (rs),
        .raddr2 (rt),
        .waddr (rf_wdest),
        .wdata (rf_wdata),
        .rdata1 (rs_value),
        .rdata2 (rt_value),

        .test_addr (rf_addr),
        .test_data (rf_data)

    );

    data_ram data_ram_module(
        .clka (clk),
        .wea (dm_wen),
        .addra (dm_addr[9:2]),
        .dina (dm_wdata),
        .douta (dm_rdata),

        .clkb (clk),
        .web (4'd0),
        .addrb (mem_addr[9:2]),
        .doutb (mem_data),
        .dinb (32'd0)
    );
    
endmodule
