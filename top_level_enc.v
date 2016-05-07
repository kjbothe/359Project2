`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:39:14 05/03/2016 
// Design Name: 
// Module Name:    top_level_enc 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top_level_enc(
	input clk,
	input reset,
	input start,
	input [127:0] message,
	input [127:0] e_key,
	input [127:0] n,
	output [127:0] c,
	output reg done
    );

	reg [127:0] counter;				//counter must go through 0-127 so use 7 bits (2^7 = 128)
	reg [127:0] mult_a, mult_b;	//inputs to multiplier
	reg [127:0] div_a, div_b;		//inputs to divider
	wire [255:0] prod;				//multiplier output (note double length)
	wire [127:0] quot;				//divider quotient output
	wire [127:0] remainder;			//divider remainder output
	
	parameter [1:0] IDLE = 2'b00,
						 KEY_LOOP = 2'b01,
						 EI_1 = 2'b10,
						 END = 2'b11;
						 
	reg [1:0] state;
	
	//128-bit sequential multiplier completes in 128 clock cycles
	rsa_mult muliply(
		.clk(clk),
		.rst(rst),
		.a(mult_a),
		.b(mult_b),
		.c_mult(prod));
	//128 sequential divider completes in 128 clock cycles	
	rsa_div divide(
		.clk(clk),
		.rst(rst),
		.a(div_a),
		.b(div_b),
		.quotient(quot),
		.remainder(remainder));
	
	always @(posedge clk) begin
		if (reset) begin 
			state = IDLE;
			counter = 0;
			cipher = 0;
		end else begin
			case(state)
				IDLE: begin
					cipher = 1'b1;
					counter = 0;
					if (e_key[127] == 1) state = EI_1;
					else state = KEY_LOOP;
				end
				
				KEY_LOOP: begin
					if (counter == e_key) state = END;
					else begin
						mult_a = cipher;
						mult_b = cipher;
						div_a = mult;
						div_b = n;
						cipher =  remainder;
						counter = counter + 1;
						e_key = e_key << 1;
						if (e_key[127]) state = EI_1;
						else state = KEY_LOOP;
					end
				end
				
				EI_1: begin
					if (counter == e_key) state = END;
					else begin
						mult_a = cipher;
						mult_b = message;
						div_a = mult;
						div_b = n;
						cipher = remainder;
						counter = counter + 1;
						e_key = e_key << 1;
						if (e_key[127]) state = EI_1;
						else state = KEY_LOOP;
					end
				end
				
			endcase
		end
	
	end

endmodule
