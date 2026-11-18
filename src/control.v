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