`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////

`define NULL 0
`define MAX_REG 256

module cpumemory #(parameter WORD_SIZE=32,FILENAME="init.coe")(
    input wire clk,
    input wire rst,
    input wire[7:0] instr_read_address,
    input wire data_mem_write,   
    input [7:0] data_address,    
    input wire[WORD_SIZE-1:0] data_write_data,
	 // outputs
    output wire[WORD_SIZE-1:0] instr_instruction,	 
    output wire[WORD_SIZE-1:0] data_read_data  
);

// ------------------------------------------
// Init memory 
// ------------------------------------------
	
reg [WORD_SIZE-1:0] buff [`MAX_REG-1:0];

initial begin 
	$readmemb(FILENAME, buff,0,255);
end 

// ------------------------------------------
// Read and Write block 
// ------------------------------------------ 

assign instr_instruction = buff[instr_read_address];
assign data_read_data = buff[data_address];
	
always @(posedge clk) begin 
	if (data_mem_write) begin 
		buff[data_address] = data_write_data;
	end
end 
endmodule
