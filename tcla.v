module tcla(
		input  [1:0] A,
		input  CIN,
		output COUT,
		output [1:0] S
	);
	
	// For carry calculation	
	wire [1:0] CARRY;
	
	assign CARRY[0] = (A[0] & CIN);				// CARRY[0]
	assign CARRY[1] = (A[1] & A[0] & CIN);		// CARRY[1]
	
	assign COUT  = CARRY[1];
	
	// Adder
	assign S = A ^ {CARRY[0], CIN};
	
endmodule 