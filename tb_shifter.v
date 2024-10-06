`timescale 1ns/1ps

module tb_shifter;
	reg  [23:0] IN;
	wire [23:0] OUT;
	reg  [7:0]  BY;
	reg  CLK;
	
	shifter sh0(
		.IN(IN),
		.BY(BY),
		.OUT(OUT)
	);
	
	initial begin
		IN  = 24'b111111111111100000111111;
		BY  = 8'b0;
		CLK = 1'b0;
	end
	
	always begin
		#1 CLK = ~CLK;
	end
	
	always@(posedge CLK) begin
		BY <= BY + 8'b1;
		if (BY == 8'b11111111) IN <= IN + 23'b1;
		
		if (BY[7] == 1'b0) begin
			if (OUT != (IN << BY)) begin
				$display("Error: Not the expected result, IN:%b, BY:%b, OUT:%b",IN,BY,OUT);
			end
		end else begin
			if (OUT != (IN >> (~BY + 1'b1))) begin
				$display("Error: Not the expected result, IN:%b, BY:%b, OUT:%b",IN,BY,OUT);
			end
		end
	end
	
endmodule 		