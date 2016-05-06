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
	input start_bit,
	input [127:0] message,
	input [127:0] e_key,
	input [127:0] n,
	output [127:0] c
    );

	reg [127:0] counter;
	reg [127:0] input1, input3;
	reg [127:0] input2, input4;
	wire [255:0] mult;
	wire [127:0] div;
	wire [127:0] remainder;
	
	parameter [1:0] IDLE = 2'b00,
						 KEY_LOOP = 2'b01,
						 EI_1 = 2'b10,
						 END = 2'b11;
						 
	reg [1:0] state;
	
	
	rsa_mult muliply(.clk(clk),.rst(rst),.a(input1),.b(input2),.c_mult(mult));
	rsa_div divide(.clk(clk),.rst(rst),.a(input3),.b(input4),.quotient(div),.remainder(remainder));
	
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
						input1 = cipher;
						input2 = cipher;
						input3 = mult;
						input4 = n;
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
						input1 = cipher;
						input2 = message;
						input3 = mult;
						input4 = n;
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
