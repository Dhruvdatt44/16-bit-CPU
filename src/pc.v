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