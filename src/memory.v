module memory(
input clk,
input mem_rd,
input mem_wr,

input [11:0] address,
input [15:0] data_in,

output reg [15:0]data_out
);

reg [15:0] mem[0:4095];

integer i;

initial begin 
  for (i=0;i<4096; i=i+1)
  mem[i] = 16'b0;

/*
mem[0] = 16'b1101_000000010100;
mem[1] = 16'b0000_000000010101;
mem[2] = 16'b0001_000000010110;
mem[3] = 16'b1110_000000010111;
mem[4] = 16'b1111_000000000000;

mem[20] = 16'd10;
mem[21] = 16'd5;
mem[22] = 16'd3;
mem[23] = 16'd0;
*/
  // 0
        mem[0] = 16'b1101_000001100100;   // LOAD 100
        // 1
        mem[1] = 16'b0000_000001100101;   // ADD 101
        // 2
        mem[2] = 16'b0001_000001100110;   // SUB 102
        // 3
        mem[3] = 16'b0010_000001100111;   // AND 103
        // 4
        mem[4] = 16'b0011_000001101000;   // OR 104
        // 5
        mem[5] = 16'b0100_000001101001;   // XOR 105
        // 6
        mem[6] = 16'b0101_000001101010;   // NAND 106
        // 7
        mem[7] = 16'b0110_000001101011;   // NOR 107
        // 8
        mem[8] = 16'b0111_000001101100;   // XNOR 108
        // 9
        mem[9] = 16'b1000_000000000000;   // NOT ACC
        // 10
        mem[10] = 16'b1001_000000000000;  // INC ACC
        // 11
        mem[11] = 16'b1010_000000000000;  // DEC ACC
        // 12
        mem[12] = 16'b1011_000001101110;  // SHL 110
        // 13
        mem[13] = 16'b1100_000001101111;  // SHR 111
        // 14
        mem[14] = 16'b1110_000001110000;  // STORE 112
        // 15
        mem[15] = 16'b1111_000000000000;  // HALT


        
        // DATA
        
        // Operand for LOAD
        mem[100] = 16'd10;
        // Operand for ADD
        mem[101] = 16'd5;
        // Operand for SUB
        mem[102] = 16'd3;
        // Operand for AND
        mem[103] = 16'd7;
        // Operand for OR
        mem[104] = 16'd2;
        // Operand for XOR
        mem[105] = 16'd6;
        // Operand for NAND
        mem[106] = 16'd3;
        // Operand for NOR
        mem[107] = 16'd12;
        // Operand for XNOR
        mem[108] = 16'd15;
       // Operand for SHL
        // ACC << 1
        mem[110] = 16'd1;
        // Operand for SHR
        // ACC >> 1
        mem[111] = 16'd1;
        // Destination for STORE
        mem[112] = 16'd0;
end 

always @(posedge clk) begin

if(mem_wr)
  mem[address]<=data_in;
  
if(mem_rd)
  data_out <= mem[address];
end


endmodule
