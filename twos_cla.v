module twos_cla(
		input  [3:0] B,
		input  CIN,
		output COUT,
		output [3:0] S
	);
	
	// For carry calculation
	
	wire [3:0] CARRY;
	
	
	
	assign CARRY[0] = (B[0] & CIN);								// CARRY[0]
	assign CARRY[1] = (B[1] & B[0] & CIN);						// CARRY[1]
	assign CARRY[2] = (B[2] & B[1] & B[0] & CIN);			// CARRY[2]
	assign CARRY[3] = (B[3] & B[2] & B[1] & B[0] & CIN);	// CARRY[3]
	
	
	assign COUT  = CARRY[3];
	
	// Adder
	assign S = B ^ {CARRY[2:0], CIN};
	
endmodule 