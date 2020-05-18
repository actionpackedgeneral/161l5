`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

`define WORD_SIZE 32
module datapath #(parameter MEM_FILE="init.coe") (
    input clk,
    input rst,
    output [5:0] instr_op,
    output [5:0] funct,
    input reg_dst,
    input branch,
    input mem_read,
    input mem_to_reg,
    input [3:0] alu_op,
    input mem_write,
    input alu_src,
    input reg_write,
    // Debug Signals
    output reg[`WORD_SIZE-1:0] prog_count,
    output reg[5:0] instr_opcode,
    output reg[4:0] reg1_addr,
    output reg[`WORD_SIZE-1:0] reg1_data,
    output reg[4:0] reg2_addr,
    output reg[`WORD_SIZE-1:0] reg2_data,
    output reg[4:0] write_reg_addr,
    output reg[`WORD_SIZE-1:0] write_reg_data 
);
// ----------------------------------------------
// Insert your solution below here
// ----------------------------------------------
// cpumemory inputs
reg [7:0] instr_read_address;
reg [7:0] pc_mux_out;
reg [7:0] data_address;
reg [ `WORD_SIZE - 1 : 0] data_write_data;

// cpumemory outputs
wire [`WORD_SIZE - 1 : 0] instr_instruction;
wire [`WORD_SIZE - 1 : 0] data_read_data;

cpumemory cpumemory(
	//inputs
	.clk(clk),.rst(rst), // each 1 bit
	.instr_read_address(instr_read_address), // 8 bit
	.data_mem_write(mem_write), // 1 bit 
	.data_address(alu_result_out[7:0]), // 8 bit
	.data_write_data(data_write_data), // 32 bit
	//outputs
	.instr_instruction(instr_instruction), // 32 bit
	.data_read_data(data_read_data) // 32 bit
	);
// overview of cpu_register module
//input wire clk, rst ,reg_write ; 
//input wire [4:0] read_register_1; 
//input wire [4:0] read_register_2 ; 
//
//input wire [4:0]  write_register; 
//input wire [`WORD_SIZE-1:0] write_data ; 
//
//output wire [`WORD_SIZE-1:0] read_data_1 ;
wire [`WORD_SIZE - 1 : 0] read_data_1;
//output wire [`WORD_SIZE-1:0] read_data_2 ;
wire [`WORD_SIZE -1 : 0] read_data_2;
// register_mux_out wire
wire [4:0] register_mux_out;

reg [`WORD_SIZE - 1 : 0] data_mux_out;

cpu_registers cpu_registers(
	.clk(clk),.rst(rst),
	.reg_write(reg_write),
	.read_register_1(instr_instruction[25:21]),
	.read_register_2(instr_instruction[20:16]),
	.write_register(register_mux_out),
	.write_data(data_mux_out),
	.read_data_1(read_data_1),
	.read_data_2(read_data_2)
	);
	
//	parameter WORD_SIZE = 32 ; 
//
//// Input and outputs 
//// Modelling with Continuous Assignments 
//
//input  wire select_in ;  
//input  wire [WORD_SIZE-1:0] datain1 ; 
//input  wire [WORD_SIZE-1:0] datain2 ; 
//output wire [WORD_SIZE-1:0] data_out ;

mux_2_1 #(.WORD_SIZE(5)) register_mux(
	.select_in(reg_dst),
	.datain1(instr_instruction[20:16]),
	.datain2(instr_instruction[15:11]),
	.data_out(register_mux_out)
	);
wire [`WORD_SIZE - 1 : 0]alu_mux_out;

mux_2_1 #(.WORD_SIZE(32)) alu_mux(
	.select_in(alu_src),
	.datain1(read_data_2),
	.datain2({{16{instr_instruction[15]}},instr_instruction[15:0]}),
	.data_out(alu_mux_out)
	);
// time for the alu
//module alu( alu_control_in,  channel_a_in , channel_b_in , zero_out , alu_result_out  );

wire [`WORD_SIZE -1 : 0] alu_result_out;
alu alu(
	.alu_control_in(alu_op),
	.channel_a_in(read_data_1),
	.channel_b_in(alu_mux_out),
	.zero_out(zero_out),
	.alu_result_out(alu_result_out)
	);

mux_2_1 #(.WORD_SIZE(32)) data_mux(
	.select_in(mem_to_reg),
	.datain1(alu_result_out),
	.datain2(data_read_data),
	.data_out(data_mux_out)
	);
mux_2_1 #(.WORD_SIZE(8)) pc_mux(
	.select_in(zero_out & branch),
	.datain1(instr_read_address + 4),
	.datain2((instr_read_address + 4) + ({{16{instr_instruction[15]}},instr_instruction[15:0]} << 2)),
	.data_out(pc_mux_out)
	);
assign instr_op = instr_instruction[31:26];
assign funct = instr_instruction[5:0];
assign pc_mux_out = instr_read_address;


initial begin
	data_address = 0;
	data_write_data = 0;
	reg1_addr = 0;
	reg2_addr = 0;
	reg1_data = 0;
	reg2_data = 0;
	write_reg_addr = 0;
	prog_count = 0;
	data_mux_out = 0;
	instr_read_address = 0;
	pc_mux_out= 0;
//	reg1_data = 0; 
end
always @ (posedge clk) begin
	// based on datapath given in lab 5
	instr_opcode <= instr_instruction[31:26]; // output cpu_memory
	prog_count <= {6'h0000_00,pc_mux_out}; //output cpu_memory
	reg1_addr <= instr_instruction[25:21]; // output cpu_memory
	reg1_data <= read_data_1; // output cpu_registers
	reg2_addr <= instr_instruction[20:16]; // output cpu_memory
	reg2_data <= read_data_2; // output cpu_registers
	write_reg_addr <= instr_instruction[15:11]; // output_cpu_memory
	write_reg_data<= data_write_data; //input cpu_registers
	pc_mux_out <= instr_read_address;
end
	

endmodule
