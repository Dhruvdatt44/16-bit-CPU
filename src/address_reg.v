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