module hcla(
		input  [1:0] A, B,
		input  CIN,
		output COUT,
		output [1:0] S
	);
	
	// For carry calculation
	
	wire [1:0] P, G; 
	assign P = A ^ B;
	assign G = A & B;
	
	wire [1:0] CARRY;
	
	assign CARRY[0] = G[0] | (P[0] & CIN);										// CARRY[0]
	assign CARRY[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & CIN);		// CARRY[1]
	
	assign COUT  = CARRY[1];
	
	// Adder
	assign S = P ^ {CARRY[0], CIN};
	
endmodule 