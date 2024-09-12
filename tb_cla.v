`timescale 1ns/1ps

module tb_cla;
	reg  [3:0] A, B;
	reg  CIN;
	
	wire [3:0] RESULT;
	wire COUT;
	reg CLK;
	
	cla cla0(
		.A(A),
		.B(B),
		.CIN(CIN),
		.COUT(COUT),
		.S(RESULT)
	);
	
	initial begin
		A = 4'b0;
		B = 4'b0;
		CIN = 1'b0;
		CLK = 1'b0;
	end
	
	always begin
		#5 CLK = ~CLK;
	end
	
	// Counter
	always@(posedge CLK) begin
		A <= A + 4'b1;
		
		if (A == 4'b1111) B <= B + 4'b1;	
		
		if ((B == 4'b1111) & (A == 4'b1111)) begin
			CIN <= 1'b1;
			$display("SUCCESS!");
		end
		
		if ((A + B + CIN) != RESULT) begin
			$display("ERROR!: Result is not the expected one");
		end
	end
endmodule 