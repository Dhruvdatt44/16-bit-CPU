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