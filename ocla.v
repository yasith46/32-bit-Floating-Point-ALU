module ocla(
		input  [3:0] A,
		input  CIN,
		output COUT,
		output [3:0] S
	);
	
	// For carry calculation
	wire [3:0] CARRY;	
	
	assign CARRY[0] = (A[0] & CIN);								// CARRY[0]
	assign CARRY[1] = (A[1] & A[0] & CIN);						// CARRY[1]
	assign CARRY[2] = (A[2] & A[1] & A[0] & CIN);			// CARRY[2]
	assign CARRY[3] = (A[3] & A[2] & A[1] & A[0] & CIN);	// CARRY[3]
		
	assign COUT  = CARRY[3];
	
	// Adder
	assign S = A ^ {CARRY[2:0], CIN};
endmodule 