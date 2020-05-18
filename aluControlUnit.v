`timescale 1ns / 1ps
module aluControlUnit (
    input wire [1:0] alu_op , 
    input wire [5:0] instruction_5_0 , 
    output reg [3:0] alu_out  
    );
// ------------------------------
// Insert your solution below
// ------------------------------ 
wire [8:0] comb;

assign comb = {alu_op,instruction_5_0};

always @ * begin

case(comb)

default: alu_out = 4'b0010;
8'bX1XXXXXX: alu_out = 4'b0110;
8'b1XXX0000: alu_out = 4'b0010;
8'b1XXX0010: alu_out = 4'b0110;
8'b1XXX0000: alu_out = 4'b0000;
8'b1XXX0101: alu_out = 4'b0001;
8'b1XXX1010: alu_out = 4'b0111;
8'b1XXX0111: alu_out = 4'b1100;

endcase

end
endmodule

