`timescale 1ns/1ps

module cpu_tb;

    //====================================================
    // INPUTS
    //====================================================

    reg clk;
    reg reset;


    //====================================================
    // CONTROL SIGNALS
    //====================================================

    wire mem_rd;
    wire mem_wr;

    wire ar_ld;
    wire ar_inc;

    wire pc_ld;
    wire pc_inc;

    wire dr_ld;

    wire accm_rst;
    wire accm_ld;
    wire accm_pass;

    wire ir_ld;

    wire [3:0] alu_ctrl;
    wire [2:0] op_mux_sel;

    wire clk_en;


    //====================================================
    // DATAPATH OUTPUTS
    //====================================================

    wire [15:0] instruction;
    wire [15:0] accumulator_out;


    //====================================================
    // DUT : DATAPATH
    //====================================================

    datapath DP (
        .clk(clk),
        .reset(reset),

        .mem_rd(mem_rd),
        .mem_wr(mem_wr),

        .ar_ld(ar_ld),
        .ar_inc(ar_inc),

        .pc_ld(pc_ld),
        .pc_inc(pc_inc),

        .dr_ld(dr_ld),

        .accm_rst(accm_rst),
        .accm_ld(accm_ld),
        .accm_pass(accm_pass),

        .ir_ld(ir_ld),

        .alu_ctrl(alu_ctrl),
        .op_mux_sel(op_mux_sel),

        .instruction(instruction),
        .accumulator_out(accumulator_out)
    );


    //====================================================
    // DUT : CONTROLLER
    //====================================================

    ctrl_unit CTRL (
        .clk(clk),
        .reset(reset),

        .instruction(instruction),

        .mem_rd(mem_rd),
        .mem_wr(mem_wr),

        .ar_ld(ar_ld),
        .ar_inc(ar_inc),

        .pc_ld(pc_ld),
        .pc_inc(pc_inc),

        .dr_ld(dr_ld),

        .accm_rst(accm_rst),
        .accm_ld(accm_ld),
        .accm_pass(accm_pass),

        .ir_ld(ir_ld),

        .alu_ctrl(alu_ctrl),
        .op_mux_sel(op_mux_sel),

        .clk_en(clk_en)
    );


    //====================================================
    // CLOCK GENERATION
    //====================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    //====================================================
    // RESET
    //====================================================

    initial begin
        reset = 1'b1;
        #20;
        reset = 1'b0;
    end


    //====================================================
    // WAVEFORM DUMP
    //====================================================

    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
    end


    //====================================================
    // CPU STATE MONITOR
    //====================================================

    always @(posedge clk) begin
        #1;

        $display(
        "TIME=%0t | T=%0d | PC=%04h | AR=%04h | IR=%04h | DR=%04h | ACC=%04h | BUS=%04h | MEM=%04h",
        $time,
        CTRL.timer,
        DP.pc_data,
        DP.ar_data,
        DP.ir_data,
        DP.dr_data,
        DP.acc_data,
        DP.bus_data,
        DP.memory_data
        );

    end


    //====================================================
    // CONTROL SIGNAL MONITOR
    //====================================================

    always @(posedge clk) begin
        #1;

        $display(
        "RD=%b WR=%b ARLD=%b ARINC=%b PCLD=%b PCINC=%b DRLD=%b IRLD=%b ACCLD=%b ACCRST=%b ACCPASS=%b MUX=%03b ALU=%04b",
        mem_rd,
        mem_wr,
        ar_ld,
        ar_inc,
        pc_ld,
        pc_inc,
        dr_ld,
        ir_ld,
        accm_ld,
        accm_rst,
        accm_pass,
        op_mux_sel,
        alu_ctrl
        );

        $display("--------------------------------------------------------------------------------");

    end


    //====================================================
    // SIMULATION END
    //====================================================

    initial begin
        #10000;

        $display("");
        $display("========================================");
        $display("      SIMULATION COMPLETED");
        $display("========================================");

        $finish;
    end

endmodule