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
 
  
  
  