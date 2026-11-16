module top(
    input         clk_100mhz,
    input         reset_sw,
    input         cpu_clk_btn,
    output [15:0] led,
    output [3:0]  D0_AN,
    output [7:0]  D0_SEG,
    output [3:0]  D1_AN,
    output [7:0]  D1_SEG
);

    
    reg [1:0]  btn_sync = 2'b00;
    reg [19:0] db_cnt   = 20'd0;      // ~10 ms at 100 MHz
    reg        cpu_clk  = 1'b0;

    always @(posedge clk_100mhz) begin
        btn_sync <= {btn_sync[0], cpu_clk_btn};
        if (btn_sync[1] == cpu_clk) begin
            db_cnt <= 20'd0;
        end else begin
            db_cnt <= db_cnt + 20'd1;
            if (db_cnt == 20'd1_000_000) begin
                cpu_clk <= btn_sync[1];
                db_cnt  <= 20'd0;
            end
        end
    end

  
    wire [15:0] accumulator_out;
    wire [15:0] instr;

    cpu u_cpu (
        .clk            (cpu_clk),
        .reset          (reset_sw),
        .accumulator_out(accumulator_out),
        .op_bus_led     (led),
        .instr          (instr)
    );

   
    reg [17:0] refresh = 18'd0;
    always @(posedge clk_100mhz) refresh <= refresh + 18'd1;

    wire [1:0] sel = refresh[17:16];

    
    function [7:0] seg_dec;
        input [3:0] n;
        reg [6:0] s;
        begin
            case (n)
                4'h0: s = 7'h3F;
                4'h1: s = 7'h06;
                4'h2: s = 7'h5B;
                4'h3: s = 7'h4F;
                4'h4: s = 7'h66;
                4'h5: s = 7'h6D;
                4'h6: s = 7'h7D;
                4'h7: s = 7'h07;
                4'h8: s = 7'h7F;
                4'h9: s = 7'h6F;
                4'hA: s = 7'h77;
                4'hB: s = 7'h7C;
                4'hC: s = 7'h39;
                4'hD: s = 7'h5E;
                4'hE: s = 7'h79;
                default: s = 7'h71;
            endcase
            seg_dec = ~{1'b0, s};
        end
    endfunction

    reg [3:0] acc_nib, ins_nib;
    always @(*) begin
        case (sel)
            2'd0: begin acc_nib = accumulator_out[3:0];   ins_nib = instr[3:0];   end
            2'd1: begin acc_nib = accumulator_out[7:4];   ins_nib = instr[7:4];   end
            2'd2: begin acc_nib = accumulator_out[11:8];  ins_nib = instr[11:8];  end
            default: begin acc_nib = accumulator_out[15:12]; ins_nib = instr[15:12]; end
        endcase
    end

    assign D0_SEG = seg_dec(acc_nib);
    assign D1_SEG = seg_dec(ins_nib);
    assign D0_AN  = ~(4'b0001 << sel);   // active low
    assign D1_AN  = ~(4'b0001 << sel);

endmodule


module cpu(
input clk,
input reset,
output[15:0] accumulator_out,
output [15:0] op_bus_led,
output [15:0] instr

);

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
    wire [15:0] instruction;
    
datapath dp (
  clk,
   reset,
   
  // controller signals
   mem_rd,
  mem_wr,
  
  ar_ld,
   ar_inc,
  
   pc_ld,
   pc_inc,
  
   dr_ld,
  
   accm_rst,
   accm_ld,
   accm_pass,
  
   ir_ld,
  
    alu_ctrl,
    op_mux_sel,
  
    instruction,
    accumulator_out ,
    op_bus_led 
    
   ); 
   assign instr = instruction;
 
 ctrl_unit control(
    clk,
    reset,

    instruction,

    mem_rd,
    mem_wr,

    ar_ld,
    ar_inc,
    pc_ld,

    pc_inc,

    dr_ld,

    accm_rst,
    accm_ld,
    accm_pass,

    ir_ld,

    alu_ctrl,

    op_mux_sel,

    clk_en  
    );
    endmodule
    
    

module ctrl_unit(
    input clk,
    input reset,

    input [15:0] instruction,
    
    output reg mem_rd,
    output reg mem_wr,

    output reg ar_ld,
    output reg ar_inc,
    output reg pc_ld,

    output reg pc_inc,

    output reg dr_ld,

    output reg accm_rst,
    output reg accm_ld,
    output reg accm_pass,

    output reg ir_ld,

    output reg [3:0] alu_ctrl,

    output reg [2:0] op_mux_sel,

    output reg clk_en
);


wire [3:0] opcode;
reg [3:0] timer;

localparam ADD =4'b0000;
localparam SUB =4'b0001;
localparam AND = 4'b0010;
localparam OR = 4'b0011;
localparam XOR = 4'b0100;
localparam NAND = 4'b0101;
localparam NOR =4'b0110;
localparam XNOR = 4'b0111;
localparam NOT = 4'b1000;
localparam INC =4'b1001;
localparam DEC = 4'b1010;
localparam SHL = 4'b1011;
localparam SHR = 4'b1100;
localparam LOAD = 4'b1101;
localparam STORE = 4'b1110;
localparam HALT = 4'b1111;

localparam t0 = 4'd0;
localparam t1 = 4'd1;
localparam t2 = 4'd2;
localparam t3 = 4'd3;
localparam t4 = 4'd4;
localparam t5 = 4'd5;
localparam t6 = 4'd6;
localparam t7 = 4'd7;

assign opcode = instruction[15:12];


always @(posedge clk or posedge reset) begin
    if(reset) begin
        timer <= t0;
    end
    else if(clk_en) begin
        case(opcode)
            HALT: begin
                timer <= timer;          // Freeze
            end
            STORE: begin
                if(timer == t5)
                    timer <= t0;
                else
                    timer <= timer + 4'd1;
            end
            default: begin              // All ALU instructions
                if(timer == t7)
                    timer <= t0;
                else
                    timer <= timer + 4'd1;
            end
        endcase
    end
end
// BUS
// 000 - no use 
// 001 - adres
// 010 pc
//011 data reg
// 100 - acc
// 101instruction reg
// 110 no use
// 111 memory
always @(*) begin
    mem_rd=1'b0;
    mem_wr = 1'b0;
    ar_ld=1'b0;
    ar_inc=1'b0;
    pc_ld=1'b0;
    pc_inc=1'b0;
    dr_ld=1'b0;
    accm_rst=1'b0;
    accm_ld=1'b0;
    accm_pass = 1'b0;
    ir_ld=1'b0;
    alu_ctrl=4'b0000;
    op_mux_sel=3'b000;
    clk_en=1'b1;
    case(timer)
    t0:begin // T0                       
        op_mux_sel = 3'b010; // put PC on bus
        ar_ld = 1'b1; // load the data of PC into address register
    end

    t1:begin // T1
        mem_rd = 1'b1;
        
    end

    t2:begin // T2
        op_mux_sel = 3'b111;
        ir_ld = 1'b1;
    end

    t3:begin // T3
        if(opcode == HALT) begin
            clk_en = 1'b0;
        end else begin
            pc_inc=1'b1;
            
        end
    end

    t4:begin // T4
        if(opcode != HALT)begin 
        
            op_mux_sel= 3'b101;
            ar_ld = 1'b1;
         end   
       
        end
  

     t5:begin // T5
           case(opcode)

                STORE: begin

                    op_mux_sel = 3'b100;
                    mem_wr = 1'b1;

                end


                LOAD,
                ADD,SUB,AND,OR,XOR,NAND,NOR,XNOR,
                NOT,INC,DEC,SHL,SHR:
                begin
                      mem_rd = 1'b1;
                      end
                    default: begin
                 end
       endcase
       end
        t6: begin

            case(opcode)

                LOAD,
                ADD,SUB,AND,OR,XOR,NAND,NOR,XNOR,
                NOT,INC,DEC,SHL,SHR:
                begin

                    op_mux_sel = 3'b111;
                    dr_ld = 1'b1;
           end
                    default: begin
                 end
       endcase
       end
       t7: begin

            case(opcode)

                ADD,SUB,AND,OR,XOR,NAND,NOR,XNOR,
                NOT,INC,DEC,SHL,SHR:
                begin

                    alu_ctrl = opcode;
                    accm_ld = 1'b1;

                end


                LOAD: begin

                    accm_pass = 1'b1;
                    accm_ld = 1'b1;

                end


                default: begin

                end
            endcase
        end
        default: begin
        end
    endcase
end
endmodule

module datapath(
  input clk,
  input reset,
  // controller signals
  input mem_rd,
  input mem_wr,
  
  input ar_ld,
  input ar_inc,
  
  input pc_ld,
  input pc_inc,
  
  input dr_ld,
  
  input accm_rst,
  input accm_ld,
  input accm_pass,
  
  input ir_ld,
  
  input [3:0] alu_ctrl,
  input [2:0] op_mux_sel,
  
  
  output [15:0] instruction,
  output [15:0] accumulator_out,
  output [15:0] op_bus_led
 );
 
 wire [15:0] pc_data;
 wire [15:0] ar_data;
 wire [15:0] dr_data;
 wire [15:0] acc_data;
 wire [15:0] ir_data;
 wire [15:0] bus_data;
 wire [15:0] memory_data;
 
 wire[15:0] alu_result;
 wire alu_zero;
 wire alu_carry;
 wire alu_overflow;

pc PC(bus_data,clk,pc_ld,reset,pc_inc,pc_data);

address_reg ar(clk,reset,bus_data,ar_ld,ar_inc,ar_data);

data_reg dr(clk,reset,bus_data,dr_ld,dr_data);

instruction_reg ir(clk,reset,bus_data,ir_ld,ir_data);

assign instruction = ir_data;

accumulator acc(clk,reset,alu_result,accm_ld,acc_data);

alu16 alu (acc_data,dr_data,alu_ctrl,accm_pass,alu_result,alu_zero,alu_carry,alu_overflow);

bus BUS(ar_data,pc_data,dr_data,acc_data,ir_data,memory_data,op_mux_sel,bus_data);

memory mem(clk,mem_rd,mem_wr,ar_data[11:0],bus_data,memory_data);

assign accumulator_out = acc_data;

assign op_bus_led = bus_data;

endmodule
 
  
  
  

module pc(
    input [15:0] data_in,
    input clk,
    input load,
    input reset,
    input inr,
    output reg [15:0] data_out
);

always @(posedge clk or posedge reset)
if(reset==1)
data_out<=16'd0;
else if(load)
data_out<=data_in;
else if(inr)
data_out<=data_out+16'd1;
else 
data_out<=data_out;
endmodule

module address_reg(
    input clk,
    input reset,
    input [15:0] data_in,
    input load,
    input inc,
    output reg [15:0] data_out
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        data_out <= 16'b0;
    end else begin
        if(load) begin
            data_out <= data_in;
        end else if(inc) begin
            data_out <= data_out + 16'b1;
        end else begin
            data_out <= data_out;
        end
    end
end

endmodule

module data_reg(
    input clk,
    input reset,
    input [15:0] data_in,
    input load,
    output reg [15:0] data_out
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        data_out <= 16'b0;
    end else begin
        if(load) begin
            data_out <= data_in;
        end else begin
            data_out <= data_out;
        end
    end
end

endmodule

module instruction_reg(
    input clk,
    input reset,
    input [15:0] data_in,
    input load,
    output reg [15:0] data_out
);

always @(posedge clk or posedge reset) begin
    if(reset) begin
        data_out <= 16'b0;
    end else begin
        if(load) begin
            data_out <= data_in;
        end else begin
            data_out <= data_out;
        end
    end
end

endmodule

module accumulator(
    input clk,
    input reset,
    input [15:0] data_in,
    input load,
    output reg [15:0] data_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        data_out <= 16'b0;
    end else begin
        if(load) begin
            data_out <= data_in;
        end else begin
            data_out <= data_out;
        end
    end
end

endmodule

module alu16( 
    input [15:0] a,
    input [15:0] b,
    input [3:0] aluctrl,
    input accm_pass,
    output reg [15:0] result,
    output zero,
    output reg carry,
    output reg overflow
);

always @(*) begin
    carry=1'b0;
    overflow=1'b0;
    if(accm_pass) begin
        result = b;
    end else begin
    case(aluctrl)
    4'b0000:begin //ADD
    {carry,result}=a+b;
    overflow=(a[15]==b[15])&&(a[15]!=result[15]);
    end
    4'b0001:begin //SUB
    {carry,result}=a-b;
    overflow=(a[15]!=b[15])&&(b[15]!=result[15]);
    end
    4'b0010:result=a&b;//LOGICAL AND
    4'b0011:result=a|b;//LOGICAL OR
    4'b0100:result=a^b;//XOR
    4'b0101:result=~(a&b);//NAND
    4'b0110:result=~(a|b);//NOR
    4'b0111:result=~(a^b);//XNOR
    4'b1000:result=~a;// ACCUMULATOR COMPLEMENT
    // CARRY FLAG INDICATES UNSIGNED OVERFLOW/BORROW
    //OVERFLOW FLAG INDICATES UNSIGNED ARITHMETIC OVERFLOW
    4'b1001:begin
        {carry,result}=a+ 16'b1;//INCREMENT A (UNSIGNED)
        overflow=(a==16'hFFFF);
    end
    4'b1010:begin
        {carry,result}=a- 16'b1;//DECREMENT A(UNSIGNED)
        overflow=(a==16'h0000);
    end
    4'b1011:result=a<<b[3:0];//LOGICAL SHIFT LEFT
    4'b1100:result=a>>b[3:0];//LOGICAL SHIFT RIGHT

    //LOAD 4'b1101
    //STORE 4'b1110
    //HALT 4'b1111
    default:result=16'd0;
    endcase
    end
end
 
 assign zero=(result==16'b0);
endmodule

module bus ( 

input [15:0] ar_data,
input [15:0] pc_data,
input [15:0] dr_data,
input [15:0] acc_data,
input [15:0] ir_data,
input [15:0] memory_data,

input [2:0] op_mux_sel,
output reg [15:0] bus_data
);

always @(*) begin
  case (op_mux_sel)
      3'b000:begin 
         bus_data = 16'b0;
      end
      3'b001:begin
        bus_data = ar_data;
      end
      3'b010:begin
        bus_data=pc_data;
      end
      3'b011:begin
        bus_data=dr_data;
      end
      3'b100:begin
        bus_data=acc_data;
      end 
      3'b101:begin 
       bus_data= {4'b0000,ir_data[11:0]};
      end
      3'b110:begin
        bus_data=16'b0;
        end
      3'b111:begin
        bus_data=memory_data;
        end
        
        default :begin
        bus_data =16'b0;
        end
        endcase
end
endmodule


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
        mem[11] = 16'b1010_101001010101;  // DEC ACC
        // 12
        mem[12] = 16'b0000_101001010101;  // SHL 110
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
