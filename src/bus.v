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
