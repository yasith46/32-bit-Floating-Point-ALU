// IEEE754 Format
// 
// +------+-------------+-------------+
// |  31  |   [30:23]   |    [22:0]   | 
// | Sign |   Exponent  |   Mantissa  |
// +------+-------------+-------------+


module alu(
		input  FPUCLK,
		input  [31:0] A, B,
		input  [2:0]  CTRL,
		output reg [31:0] OUT
	);
	
	
	
	// For exponents
	reg  EXPCIN;				// Add or subtract the exponents
	wire [7:0] EXPDIF_w;		// Result of exponents (for pipeline stage1)
	wire COUT_EX;
		
	cla claexp_0(.A(A[26:23]), .B(B[26:23]^{4{EXPCIN}}), .CIN(EXPCIN),  .COUT(COUT_EX), .S(EXPDIF_w[3:0]));	
	cla claexp_1(.A(A[30:27]),	.B(B[30:27]^{4{EXPCIN}}), .CIN(COUT_EX), .COUT(),        .S(EXPDIF_w[7:4]));
	
	
	
	reg [7:0] EXPDIF0;
	
	// For shifter
	reg [23:0] TBSHIFTED;
	wire [23:0] SHIFTOUT_w;
	
	shifter shift_0(.IN(TBSHIFTED), .BY(EXPDIF0), .OUT(SHIFTOUT_w));
	
	// For operations
	reg  [23:0] A_ALUIN, B_ALUIN;
	wire [23:0] ALUOUT;
	reg ALUCIN;
	wire OVERFLOW;
	
	cla_add cla_add0(
		.A(A_ALUIN),
		.B(B_ALUIN),
		.CIN(ALUCIN),
		.OUT(ALUOUT),
		.OF(OVERFLOW)
	);
	
	
	// Signres
	wire COUT_SRES;
	wire [7:0] EXPSRES;
	reg [7:0]  EXPCARRY;						// Exp of greater to be carried
	
	cla clasresexp_0(.A(EXPCARRY[3:0]),	.B(4'b1), .CIN(1'b0),      .COUT(COUT_SRES), .S(EXPSRES[3:0]));
	cla clasresexp_1(.A(EXPCARRY[7:4]),	.B(4'b0), .CIN(COUT_SRES), .COUT(),       	.S(EXPSRES[7:4]));
	
	// For sign resolution
	reg  [22:0] TWOSIN;
	wire [22:0] TWOSOUT;
	
	twoscomp twosconv0(
		.B(TWOSIN),
		.OUT(TWOSOUT)
	);
	
	// Pipeline registers
	reg [23:0] APP0, APP1, BPP0, BPP1;	// Pipeline registers for number and cmd
	reg [31:0] OUT0;
	reg ASIGN0, ASIGN1, BSIGN0, BSIGN1, RESNEEDED;
	reg [2:0]  CTRL1, CTRL2, CTRL3;
	
	// codes
	parameter ADD = 3'b000, SUB = 3'b001;
	
	reg ST1_DONE, ST2_DONE, ST3_DONE, ST4_DONE;
	
	
	
	// Combinational parts of each stage 
	
	always@(*) begin
		// -----------------------------------
		// Stage 1 : Exponent calculation
		// -----------------------------------
		if (CTRL == ADD | CTRL == SUB) begin
			EXPCIN <= 1'b1;
		end else begin
			EXPCIN <= 1'b0;
		end
		
		// -----------------------------------
		// Stage 2 : Shifting
		// -----------------------------------
		if (CTRL1 == ADD | CTRL1 == SUB) begin			
			// Deciding which to be shifted					
			if (EXPDIF0[7] == 1'b0) begin			// exp(A) > exp(B), shift B to right
				TBSHIFTED <= BPP0;
			end else begin								// exp(B) > exp(A), shift A to right
				TBSHIFTED <= APP0;		
			end
		end else begin
			TBSHIFTED <= 24'bX;
		end
		
		
		// -----------------------------------
		// Stage 3 : Operation
		// -----------------------------------
		if (CTRL2 == ADD) begin		
			if (((ASIGN1 == 1'b0) & (BSIGN1 == 1'b0)) | ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b1))) begin 	// if signs are the same
				A_ALUIN <= APP1;
				B_ALUIN <= BPP1;
				ALUCIN  <= 1'b0;
			end else if ((ASIGN1 == 1'b0) & (BSIGN1 == 1'b1)) begin
				A_ALUIN <= APP1;	// (+A) + (-B) = (A-B)
				B_ALUIN <= BPP1;
				ALUCIN  <= 1'b1;				
			end else if ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b0)) begin
				A_ALUIN <= BPP1;	// Flipping (-A)+(+B) = (B-A)
				B_ALUIN <= APP1;
				ALUCIN  <= 1'b1;				
			end else begin
				A_ALUIN <= 24'bX;
				B_ALUIN <= 24'bX;
				ALUCIN  <= 1'bX;
			end			
		end else if (CTRL2 == SUB) begin
			if (((ASIGN1 == 1'b0) & (BSIGN1 == 1'b1)) | ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b0))) begin 	// if signs are different
				A_ALUIN <= APP1;
				B_ALUIN <= BPP1;
				ALUCIN  <= 1'b0;				
			end else if ((ASIGN1 == 1'b0) & (BSIGN1 == 1'b0)) begin
				A_ALUIN <= APP1;	// (+A) - (+B) = (A-B)
				B_ALUIN <= BPP1;
				ALUCIN  <= 1'b1;				
			end else if ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b0)) begin
				A_ALUIN <= BPP1;	// Flipping (-A)-(-B) = (B-A)
				B_ALUIN <= APP1;
				ALUCIN  <= 1'b1;
			end else begin
				A_ALUIN <= 24'bX;
				B_ALUIN <= 24'bX;
				ALUCIN  <= 1'bX;
			end	
		end else begin
			A_ALUIN <= 24'bX;
			B_ALUIN <= 24'bX;
			ALUCIN  <= 1'bX;
		end
	
		// -----------------------------------
		// Stage 4 : Sign resolution
		// -----------------------------------
		if ((CTRL3 == ADD)|(CTRL3 == SUB)) begin
			if (RESNEEDED == 1'b1) begin
				TWOSIN <= {OUT0[22:0]};
			end else begin
				TWOSIN <= 23'bX;
			end
		end else begin
			TWOSIN <= 23'bX;
		end
	end
	
	
	// Let ADD be 3'b000
	always@(posedge FPUCLK) begin		
		// -----------------------------------
		// Stage 1 : Exponent calculation
		// -----------------------------------
		
		if (CTRL == ADD | CTRL == SUB) begin
			APP0    <= {1'b1,A[22:0]};
			BPP0    <= {1'b1,B[22:0]};
			ASIGN0  <= A[31];
			BSIGN0  <= B[31];
		
			EXPDIF0 <= EXPDIF_w;
			CTRL1	  <= CTRL;
		end
		
		
		// -----------------------------------
		// Stage 2 : Shifting
		// -----------------------------------
		if (CTRL1 == ADD | CTRL1 == SUB) begin
			CTRL2  <= CTRL1;					
			ASIGN1 <= ASIGN0;
			BSIGN1 <= BSIGN0;
			
			// Deciding which to be shifted					
			if (EXPDIF0[7] == 1'b0) begin			// exp(A) > exp(B), shift B to right
				APP1      <= APP0;
				BPP1      <= SHIFTOUT_w;
				EXPCARRY  <= A[30:23]; 
			end else begin									// exp(B) > exp(A), shift A to right
				APP1  	 <= SHIFTOUT_w;
				BPP1      <= BPP0;
				EXPCARRY  <= B[30:23];					
			end
		end
		
		
		// -----------------------------------
		// Stage 3 : Operation
		// -----------------------------------
		if (CTRL2 == ADD) begin
			CTRL3 <= CTRL2;
		
			if (((ASIGN1 == 1'b0) & (BSIGN1 == 1'b0)) | ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b1))) begin 	// if signs are the same
				RESNEEDED <= 1'b0;
						
				if (OVERFLOW == 1'b0) begin
					OUT0 <= {ASIGN1, EXPCARRY, ALUOUT[22:0]};
				end else begin
					OUT0 <= {ASIGN1, EXPSRES, ALUOUT[23:1]};	// If carried over
				end
				
			end else if ((ASIGN1 == 1'b0) & (BSIGN1 == 1'b1)) begin
				OUT0 <= {~{ALUOUT[23]}, EXPCARRY, ALUOUT[22:0]};
				
				if (OVERFLOW == 1'b0) begin
					RESNEEDED <= 1'b1;
				end else begin
					RESNEEDED <= 1'b0;
				end
				
			end else if ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b0)) begin
				OUT0 <= {~{ALUOUT[23]}, EXPCARRY, ALUOUT[22:0]};
				
				if (OVERFLOW == 1'b0) begin
					RESNEEDED <= 1'b1;
				end else begin
					RESNEEDED <= 1'b0;
				end
			end
			
		end else if (CTRL2 == SUB) begin
			CTRL3 <= CTRL2;
			
			if (((ASIGN1 == 1'b0) & (BSIGN1 == 1'b1)) | ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b0))) begin 	// if signs are different
				RESNEEDED <= 1'b0;
				
				if (OVERFLOW == 1'b0) begin
					OUT0 <= {ASIGN1, EXPCARRY, ALUOUT[22:0]};
				end else begin
					OUT0 <= {ASIGN1, EXPSRES, ALUOUT[23:1]};	// If carried over
				end
				
			end else if ((ASIGN1 == 1'b0) & (BSIGN1 == 1'b0)) begin
				OUT0 <= {~{ALUOUT[23]}, EXPCARRY, ALUOUT[22:0]};
				
				if (OVERFLOW == 1'b0) begin
					RESNEEDED <= 1'b1;
				end else begin
					RESNEEDED <= 1'b0;
				end
				
			end else if ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b0)) begin
				OUT0 <= {~{ALUOUT[23]}, EXPCARRY, ALUOUT[22:0]};
				
				if (OVERFLOW == 1'b0) begin
					RESNEEDED <= 1'b1;
				end else begin
					RESNEEDED <= 1'b0;
				end
			end
		end
		
		
		// -----------------------------------
		// Stage 4 : Sign resolution
		// -----------------------------------
		if ((CTRL3 == ADD)|(CTRL3 == SUB)) begin
			if (RESNEEDED == 1'b1) begin
				OUT <= {OUT0[31:23],TWOSOUT};
			end else begin
				OUT <= OUT0;
			end
		end
	end
endmodule 