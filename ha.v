module ha(
		input  A, B,
		output SUM, COUT
	);
	
	assign SUM  = A^B;
	assign COUT = A&B;
endmodule 	