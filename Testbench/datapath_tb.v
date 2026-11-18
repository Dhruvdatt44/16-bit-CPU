`timescale 1ns/1ps

// ---------------------------------------------------------------
// Full-system testbench: ctrl_unit + datapath (with your alu16)
// Covers ALL instructions: ADD SUB AND OR XOR NAND NOR XNOR
//                          NOT INC DEC SHL SHR LOAD STORE HALT
// !! Change MEM_ARRAY to the real array name in your `memory` module.
// ---------------------------------------------------------------
`define MEM_ARRAY dp.mem.mem

module datapath_test;

    localparam ADD=4'h0, SUB=4'h1, AND=4'h2, OR=4'h3, XOR=4'h4, NAND=4'h5,
               NOR=4'h6, XNOR=4'h7, NOT=4'h8, INC=4'h9, DEC=4'hA,
               SHL=4'hB, SHR=4'hC, LOAD=4'hD, STORE=4'hE, HALT=4'hF;

    reg clk, reset;

    wire mem_rd, mem_wr, ar_ld, ar_inc, pc_ld, pc_inc, dr_ld;
    wire accm_rst, accm_ld, accm_pass, ir_ld, clk_en;
    wire [3:0]  alu_ctrl;
    wire [2:0]  op_mux_sel;
    wire [15:0] instruction, accumulator_out;

    integer errors, i;

    // expected ACC after each of the 15 ACC-updating instructions
    reg [15:0] expected [0:14];
    reg [8*8-1:0] names [0:14];

    ctrl_unit cu (
        .clk(clk), .reset(reset), .instruction(instruction),
        .mem_rd(mem_rd), .mem_wr(mem_wr),
        .ar_ld(ar_ld), .ar_inc(ar_inc), .pc_ld(pc_ld), .pc_inc(pc_inc),
        .dr_ld(dr_ld), .accm_rst(accm_rst), .accm_ld(accm_ld),
        .accm_pass(accm_pass), .ir_ld(ir_ld),
        .alu_ctrl(alu_ctrl), .op_mux_sel(op_mux_sel), .clk_en(clk_en)
    );

    datapath dp (
        .clk(clk), .reset(reset),
        .mem_rd(mem_rd), .mem_wr(mem_wr),
        .ar_ld(ar_ld), .ar_inc(ar_inc), .pc_ld(pc_ld), .pc_inc(pc_inc),
        .dr_ld(dr_ld), .accm_rst(accm_rst), .accm_ld(accm_ld),
        .accm_pass(accm_pass), .ir_ld(ir_ld),
        .alu_ctrl(alu_ctrl), .op_mux_sel(op_mux_sel),
        .instruction(instruction), .accumulator_out(accumulator_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task cycles(input integer n);
        begin repeat (n) @(posedge clk); end
    endtask

    task check_acc(input [15:0] exp, input [8*8-1:0] name);
        begin
            #1;
            if (accumulator_out !== exp) begin
                $display("[FAIL] %-6s : ACC = %h, expected %h (t=%0t)", name, accumulator_out, exp, $time);
                errors = errors + 1;
            end else
                $display("[PASS] %-6s : ACC = %h", name, accumulator_out);
        end
    endtask

    initial begin
        errors = 0;
        reset  = 1;

        for (i = 0; i < 4096; i = i + 1) `MEM_ARRAY[i] = 16'h0000;

        // ---------------- Program ----------------
        `MEM_ARRAY[0]  = {LOAD , 12'h100};  // ACC = 00F0
        `MEM_ARRAY[1]  = {ADD  , 12'h109};  // + 0010 = 0100
        `MEM_ARRAY[2]  = {SUB  , 12'h10A};  // - 0001 = 00FF
        `MEM_ARRAY[3]  = {AND  , 12'h10B};  // & 000F = 000F
        `MEM_ARRAY[4]  = {OR   , 12'h10C};  // | 0070 = 007F
        `MEM_ARRAY[5]  = {XOR  , 12'h10D};  // ^ 0055 = 002A
        `MEM_ARRAY[6]  = {LOAD , 12'h100};  // ACC = 00F0
        `MEM_ARRAY[7]  = {NAND , 12'h101};  // ~(00F0 & 0FF0) = FF0F
        `MEM_ARRAY[8]  = {NOR  , 12'h102};  // ~(FF0F | 00FF) = 0000
        `MEM_ARRAY[9]  = {XNOR , 12'h103};  // ~(0000 ^ 1234) = EDCB
        `MEM_ARRAY[10] = {NOT  , 12'h104};  // ~EDCB = 1234
        `MEM_ARRAY[11] = {INC  , 12'h105};  // 1235
        `MEM_ARRAY[12] = {DEC  , 12'h106};  // 1234
        `MEM_ARRAY[13] = {SHL  , 12'h107};  // 1234 << 4 = 2340  (shift amt = M[107][3:0])
        `MEM_ARRAY[14] = {SHR  , 12'h108};  // 2340 >> 8 = 0023  (shift amt = M[108][3:0])
        `MEM_ARRAY[15] = {STORE, 12'h110};  // M[110] = ACC
        `MEM_ARRAY[16] = {HALT , 12'h000};

        // ---------------- Data ----------------
        `MEM_ARRAY[12'h100] = 16'h00F0;
        `MEM_ARRAY[12'h101] = 16'h0FF0;
        `MEM_ARRAY[12'h102] = 16'h00FF;
        `MEM_ARRAY[12'h103] = 16'h1234;
        `MEM_ARRAY[12'h104] = 16'h0000;  // unused operand (NOT)
        `MEM_ARRAY[12'h105] = 16'h0000;  // unused operand (INC)
        `MEM_ARRAY[12'h106] = 16'h0000;  // unused operand (DEC)
        `MEM_ARRAY[12'h107] = 16'h0004;  // SHL amount
        `MEM_ARRAY[12'h108] = 16'h0008;  // SHR amount
        `MEM_ARRAY[12'h109] = 16'h0010;
        `MEM_ARRAY[12'h10A] = 16'h0001;
        `MEM_ARRAY[12'h10B] = 16'h000F;
        `MEM_ARRAY[12'h10C] = 16'h0070;
        `MEM_ARRAY[12'h10D] = 16'h0055;

        expected[0]=16'h00F0; names[0]="LOAD";
        expected[1]=16'h0100; names[1]="ADD";
        expected[2]=16'h00FF; names[2]="SUB";
        expected[3]=16'h000F; names[3]="AND";
        expected[4]=16'h007F; names[4]="OR";
        expected[5]=16'h002A; names[5]="XOR";
        expected[6]=16'h00F0; names[6]="LOAD";
        expected[7]=16'hFF0F; names[7]="NAND";
        expected[8]=16'h0000; names[8]="NOR";
        expected[9]=16'hEDCB; names[9]="XNOR";
        expected[10]=16'h1234; names[10]="NOT";
        expected[11]=16'h1235; names[11]="INC";
        expected[12]=16'h1234; names[12]="DEC";
        expected[13]=16'h2340; names[13]="SHL";
        expected[14]=16'h0023; names[14]="SHR";

        // ---------------- Reset ----------------
        cycles(2);
        @(negedge clk);
        reset = 0;

        // Each non-STORE/HALT instruction takes 8 cycles (T0..T7)
        for (i = 0; i < 15; i = i + 1) begin
            cycles(8);
            check_acc(expected[i], names[i]);
        end

        // STORE takes 6 cycles (T0..T5)
        cycles(6);
        #1;
        if (`MEM_ARRAY[12'h110] !== 16'h0023) begin
            $display("[FAIL] STORE  : M[110] = %h, expected 0023", `MEM_ARRAY[12'h110]);
            errors = errors + 1;
        end else
            $display("[PASS] STORE  : M[110] = %h", `MEM_ARRAY[12'h110]);

        // HALT: clk_en goes low, ACC unchanged
        cycles(8);
        if (clk_en !== 1'b0) begin
            $display("[FAIL] HALT   : clk_en still 1");
            errors = errors + 1;
        end else
            $display("[PASS] HALT   : clk_en = 0");
        check_acc(16'h0023, "ACC@HALT");

        if (errors == 0) $display("\n*** ALL TESTS PASSED ***");
        else             $display("\n*** %0d TEST(S) FAILED ***", errors);
        $finish;
    end

    initial begin #10000; $display("TIMEOUT"); $finish; end

    initial begin
        $dumpfile("cpu_tb_all_ops.vcd");
        $dumpvars(0, cpu_tb_all_ops);
    end

endmodule