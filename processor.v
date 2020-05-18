`timescale 1ns / 1ps

module processor #(parameter WORD_SIZE=32,MEM_FILE="init.coe")(
    input clk,
    input rst,   
	 // Debug signals 
    output reg[WORD_SIZE-1:0] prog_count, 
    output reg[5:0] instr_opcode,
    output reg[4:0] reg1_addr,
    output reg[WORD_SIZE-1:0] reg1_data,
    output reg[4:0] reg2_addr,
    output reg[WORD_SIZE-1:0] reg2_data,
    output reg[4:0] write_reg_addr,
    output reg[WORD_SIZE-1:0] write_reg_data 
);

// ----------------------------------------------
// Insert solution below here
// ----------------------------------------------
//module datapath #(parameter MEM_FILE="init.coe") (
//    input clk,
//    input rst,
//    output [5:0] instr_op,
//    output [5:0] funct,
//    input reg_dst,
//    input branch,
//    input mem_read,
//    input mem_to_reg,
//    input [3:0] alu_op,
//    input mem_write,
//    input alu_src,
//    input reg_write,
//    // Debug Signals
//    output reg[`WORD_SIZE-1:0] prog_count,
//    output reg[5:0] instr_opcode,
//    output reg[4:0] reg1_addr,
//    output reg[`WORD_SIZE-1:0] reg1_data,
//    output reg[4:0] reg2_addr,
//    output reg[`WORD_SIZE-1:0] reg2_data,
//    output reg[4:0] write_reg_addr,
//    output reg[`WORD_SIZE-1:0] write_reg_data 
//);
wire [5:0] debug_opcode;
wire [5:0] opcode;
wire [5:0] function_code;
wire [WORD_SIZE - 1 : 0] pc;
// for some reason it bitches when you use the same name
wire [4:0] reg1_address;
wire [WORD_SIZE -1 : 0] register_1_data;
wire [4:0] reg2_address;
wire [WORD_SIZE - 1 : 0] register_2_data;
wire [3:0] alu_out;
wire [4:0]write_reg_address;
wire [31:0]write_register_data;
datapath datapath(
	//inputs
	.clk(clk),.rst(rst), //1 bit
	.reg_dst(reg_dst), // 1
	.branch(branch),  // 1
	.mem_read(mem_read),  // 1
	.alu_op(alu_out), // 4 bits [3:0]
	.mem_write(mem_write), // 1
	.alu_src(alu_src), // 1
	.reg_write(reg_write), // 1
	.mem_to_reg(mem_to_reg),
	
	//outputs
	.instr_op(opcode), // 6 bits
	.funct(function_code), // 6 bits

	// debug signals
	.prog_count(pc), // 32
	.instr_opcode(debug_opcode), // 6
	.reg1_addr(reg1_address), // 5
	.reg1_data(register_1_data), // 32 we don't know this yet
	.reg2_addr(reg2_address), // 5
	.reg2_data(register_2_data), // 32
	.write_reg_addr(write_reg_address), // 5
	.write_reg_data(write_register_data) // 32
	);
// Hierarchy
// Processor
// -Datapath
// -- REGFILE MEMORY ALU
// -aluControlUnit
// -controlUnit
wire [1:0] alu_op;
controlUnit controlUnit (
	.instr_op(opcode),
	.reg_dst(reg_dst),
	.branch(branch),
	.mem_read(mem_read),
	.mem_to_reg(mem_to_reg),
	.alu_op(alu_op),
	.mem_write(mem_write),
	.alu_src(alu_src),
	.reg_write(reg_write)
	);
aluControlUnit aluControlUnit(
	.alu_op(alu_op),
	.instruction_5_0(function_code),
	.alu_out(alu_out)
	);

initial begin
instr_opcode = 0;
prog_count = 0;
reg1_addr = 0;
reg2_addr = 0;
reg1_data = 0;
reg2_data = 0;
end

always @ (posedge clk) begin
	instr_opcode <= debug_opcode;
	prog_count <= pc;
	reg1_addr <= reg1_address;
	reg2_addr <= reg2_address;
	reg1_data <= register_1_data;
	reg2_data <= register_2_data;
	write_reg_addr <= write_reg_address;
	write_reg_data <= write_register_data;
	
end
	
	
endmodule
