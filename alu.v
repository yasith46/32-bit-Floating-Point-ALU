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
	
	
	// Pipeline registers
	reg [23:0] APP0, APP1, BPP0, BPP1, RESM;	// Pipeline registers for number and cmd
	reg [31:0] OUT0;
	reg ASIGN0, ASIGN1, BSIGN0, BSIGN1, SIGN, OF0;
	reg [2:0]  CTRL1, CTRL2, CTRL3;
	reg [7:0] EXPONENT;
	
		
	// For exponents
	reg  EXPCIN;				// Add or subtract the exponents
	wire [7:0] EXPDIF_w;		// Result of exponents (for pipeline stage1)
	wire COUT_EX;
	reg [7:0]  EXPCARRY0, EXPCARRY1;						// Exp of greater to be carried
	reg  EXPZFLAG0, EXPZFLAG1, EXPZFLAG2;
		
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
	
	// For sign resolution
	wire [23:0] TWOSOUT;
	
	twoscomp twosconv0(
		.B(ALUOUT),
		.OUT(TWOSOUT)
	);
	
	// Normalising
	wire [22:0] NORMOUT;
	wire NORMFLAG, NORMZERO;
	wire [7:0] NORM_SHIFT;
	
	normal normalize0(
		.IN(RESM),
		.INOF(OF0),
		.OUT(NORMOUT),
		.COUNT(NORM_SHIFT),
		.ZEROFLAG(NORMZERO)
	);
	
	// Signres
	wire COUT_SRES;
	wire [7:0] EXPSRES;
	
	cla clasresexp_0(.A(EXPCARRY1[3:0]),	.B(NORM_SHIFT[3:0]), .CIN(1'b0),      .COUT(COUT_SRES), .S(EXPSRES[3:0]));
	cla clasresexp_1(.A(EXPCARRY1[7:4]),	.B(NORM_SHIFT[7:4]), .CIN(COUT_SRES), .COUT(),          .S(EXPSRES[7:4]));
	
	// codes
	parameter ADD = 3'b000, SUB = 3'b001;
	
	
	
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
			if ((EXPZFLAG2 == 1'b1) & (NORMZERO == 1'b1)) begin
				EXPONENT <= 8'b0;
			end else begin
				EXPONENT <= EXPSRES;
			end
		end else begin
			EXPONENT <= EXPSRES;			// TO BE CHANGED!!!
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
		
		if (EXPDIF_w == 8'b0) begin
			EXPZFLAG0 <= 1'b1;
		end else begin
			EXPZFLAG0 <= 1'b0;
		end
		
		
		// -----------------------------------
		// Stage 2 : Shifting
		// -----------------------------------
		if (CTRL1 == ADD | CTRL1 == SUB) begin
			EXPZFLAG1 <= EXPZFLAG0;
			CTRL2  <= CTRL1;					
			ASIGN1 <= ASIGN0;
			BSIGN1 <= BSIGN0;
			
			// Deciding which to be shifted					
			if (EXPDIF0[7] == 1'b0) begin			// exp(A) > exp(B), shift B to right
				APP1      <= APP0;
				BPP1      <= SHIFTOUT_w;
				EXPCARRY0  <= A[30:23]; 
			end else begin									// exp(B) > exp(A), shift A to right
				APP1  	 <= SHIFTOUT_w;
				BPP1      <= BPP0;
				EXPCARRY0  <= B[30:23];					
			end
		end
		
		
		// -----------------------------------
		// Stage 3 : Operation
		// -----------------------------------
		if (CTRL2 == ADD) begin
			EXPZFLAG2 <= EXPZFLAG1;
			CTRL3 <= CTRL2;
		
			if (((ASIGN1 == 1'b0) & (BSIGN1 == 1'b0)) | ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b1))) begin 	// if signs are the same
				RESM <= ALUOUT;
				OF0  <= OVERFLOW;
				EXPCARRY1 <= EXPCARRY0;
				SIGN <= ASIGN1;
				
			end else if ((ASIGN1 == 1'b0) & (BSIGN1 == 1'b1)) begin
				
				if (OVERFLOW == 1'b0) begin
					RESM <= TWOSOUT;
				end else begin
					RESM <= ALUOUT;
				end
				
				OF0 <= 1'b0;
				EXPCARRY1 <= EXPCARRY0;
				SIGN <= ~OVERFLOW;
				
			end else if ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b0)) begin
				
				if (OVERFLOW == 1'b0) begin
					RESM <= TWOSOUT;
				end else begin
					RESM <= ALUOUT;
				end
				
				OF0 <= 1'b0;
				EXPCARRY1 <= EXPCARRY0;
				SIGN <= ~OVERFLOW;
			end
			
		end else if (CTRL2 == SUB) begin
			CTRL3 <= CTRL2;
			EXPZFLAG2 <= EXPZFLAG1;
			
			if (((ASIGN1 == 1'b0) & (BSIGN1 == 1'b1)) | ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b0))) begin 	// if signs are different
				RESM <= ALUOUT;
				OF0 <= OVERFLOW;
				EXPCARRY1 <= EXPCARRY0;
				SIGN <= ASIGN1;
				
			end else if ((ASIGN1 == 1'b0) & (BSIGN1 == 1'b0)) begin
				if (OVERFLOW == 1'b0) begin
					RESM <= TWOSOUT;
				end else begin
					RESM <= ALUOUT;
				end
				
				OF0 <= 1'b0;
				EXPCARRY1 <= EXPCARRY0;
				SIGN <= ~OVERFLOW;
				
			end else if ((ASIGN1 == 1'b1) & (BSIGN1 == 1'b0)) begin
				if (OVERFLOW == 1'b0) begin
					RESM <= TWOSOUT;
				end else begin
					RESM <= ALUOUT;
				end
				
				OF0 <= 1'b0;
				EXPCARRY1 <= EXPCARRY0;
				SIGN <= ~OVERFLOW;
			end
		end
		
		
		// -----------------------------------
		// Stage 4 : Sign resolution
		// -----------------------------------
		if ((CTRL3 == ADD)|(CTRL3 == SUB)) begin
			OUT <= {SIGN, EXPONENT, NORMOUT};
		end
	end
endmodule 