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
	
	// codes
	parameter ADD = 3'b000, SUB = 3'b001, MUL = 3'b010;
	
	// Pipeline registers
	reg [23:0] APP0, APP1, BPP0, BPP1, RESM;	// Pipeline registers for number and cmd
	reg [31:0] OUT0;
	reg ASIGN0, ASIGN1, BSIGN0, BSIGN1, SIGN, OF0;
	reg [2:0]  CTRL1, CTRL2, CTRL3;
	reg [7:0] EXPONENT;
	
		
	// For exponents
	reg  EXPCIN;				// Add or subtract the exponents
	wire [7:0] EXPCAL_w_int, EXPCAL_w;		// Result of exponents (for pipeline stage1)
	wire COUT_EX0, COUT_EX1;
	reg  [7:0]  EXPCARRY0, EXPCARRY1, ADDNORM;						// Exp of greater to be carried
	reg  EXPZFLAG0, EXPZFLAG1, EXPZFLAG2;
		
	cla claexp_00(.A(A[26:23]), .B(B[26:23]^{4{EXPCIN}}), .CIN(EXPCIN),   .COUT(COUT_EX0), .S(EXPCAL_w_int[3:0]));	
	cla claexp_01(.A(A[30:27]), .B(B[30:27]^{4{EXPCIN}}), .CIN(COUT_EX0), .COUT(),         .S(EXPCAL_w_int[7:4]));
	
	cla claexp_10(.A(EXPCAL_w_int[3:0]), .B(ADDNORM[3:0]), .CIN(1'b0),     .COUT(COUT_EX1), .S(EXPCAL_w[3:0]));	
	cla claexp_11(.A(EXPCAL_w_int[7:4]), .B(ADDNORM[7:4]), .CIN(COUT_EX1), .COUT(),         .S(EXPCAL_w[7:4]));
	
	
	
	reg [7:0] EXPCAL0;
	
	// For shifter
	reg [23:0] TBSHIFTED;
	wire [23:0] SHIFTOUT_w;
	
	shifter shift_0(.IN(TBSHIFTED), .BY(EXPCAL0), .OUT(SHIFTOUT_w));
	
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
	wire [7:0] NORM_SHIFT, NORM_SHAMT;
	reg  [7:0] NORM_MULSHIFT;
	
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
	
	assign NORM_SHAMT = (CTRL3 == MUL) ? NORM_MULSHIFT : NORM_SHIFT;
	
	cla clasresexp_0(.A(EXPCARRY1[3:0]),	.B(NORM_SHAMT[3:0]), .CIN(1'b0),      .COUT(COUT_SRES), .S(EXPSRES[3:0]));
	cla clasresexp_1(.A(EXPCARRY1[7:4]),	.B(NORM_SHAMT[7:4]), .CIN(COUT_SRES), .COUT(),          .S(EXPSRES[7:4]));
	
	
	
	// multipliers
	// LAYER 1
	wire [2:0]  WML1_12;
	wire [4:0]  WML1_34;
	wire [6:0]  WML1_56;
	wire [8:0]  WML1_78;
	wire [10:0] WML1_910;
	wire [12:0] WML1_1112;
	wire [14:0] WML1_1314;
	wire [16:0] WML1_1516;
	wire [18:0] WML1_1718;
	wire [20:0] WML1_1920;
	wire [22:0] WML1_2122;
	wire [24:0] WML1_2324;
	
	reg [2:0]  RML1_12;
	reg [4:0]  RML1_34;
	reg [6:0]  RML1_56;
	reg [8:0]  RML1_78;
	reg [10:0] RML1_910;
	reg [12:0] RML1_1112;
	reg [14:0] RML1_1314;
	reg [16:0] RML1_1516;
	reg [18:0] RML1_1718;
	reg [20:0] RML1_1920;
	reg [22:0] RML1_2122;
	reg [24:0] RML1_2324;
		
	mul_l1 l1(.A(APP0), .B(BPP0), .OUT12(WML1_12), .OUT34(WML1_34), .OUT56(WML1_56), .OUT78(WML1_78), .OUT910(WML1_910), .OUT1112(WML1_1112), 
				 .OUT1314(WML1_1314), .OUT1516(WML1_1516), .OUT1718(WML1_1718), .OUT1920(WML1_1920), .OUT2122(WML1_2122), .OUT2324(WML1_2324));
				 
	wire [5:0]  WML2_1234;
	wire [9:0]  WML2_5678;
	wire [13:0] WML2_9101112;
	wire [17:0] WML2_13141516;
	wire [21:0] WML2_17181920;
	wire [24:0] WML2_21222324;
				 
	mul_l2 l2(.W12(RML1_12), .W34(RML1_34), .W56(RML1_56), .W78(RML1_78), .W910(RML1_910), .W1112(RML1_1112), .W1314(RML1_1314), .W1516(RML1_1516), 
				 .W1718(RML1_1718), .W1920(RML1_1920), .W2122(RML1_2122), .W2324(RML1_2324), .OUT1234(WML2_1234), .OUT5678(WML2_5678),
				 .OUT9101112(WML2_9101112), .OUT13141516(WML2_13141516), .OUT17181920(WML2_17181920), .OUT21222324(WML2_21222324));
				 
	wire [10:0] WML3_12345678;
	wire [18:0] WML3_910111213141516;
	wire [24:0] WML3_1718192021222324;
	
	reg [10:0] RML3_12345678;
	reg [18:0] RML3_910111213141516;
	reg [24:0] RML3_1718192021222324;
				 
	mul_l3 l3(.W1234(WML2_1234), .W5678(WML2_5678), .W9101112(WML2_9101112), .W13141516(WML2_13141516), .W17181920(WML2_17181920), 
				 .W21222324(WML2_21222324), .OUT12345678(WML3_12345678), .OUT910111213141516(WML3_910111213141516), 
				 .OUT1718192021222324(WML3_1718192021222324));
				 
	wire [19:0] WML4_12345678910111213141516;
	wire [24:0] WML4_1718192021222324;
				 
	mul_l4 l4(.W12345678(RML3_12345678), .W910111213141516(RML3_910111213141516), .W1718192021222324(RML3_1718192021222324), 
				 .OUT12345678910111213141516(WML4_12345678910111213141516), .OUT1718192021222324(WML4_1718192021222324));
				 
	wire [24:0] WML5_OUT;
				 
	mul_l5 l5(.W12345678910111213141516(WML4_12345678910111213141516), .W1718192021222324(WML4_1718192021222324), .OUT(WML5_OUT));
	
	// Combinational parts of each stage 
	
	always@(*) begin
		// -----------------------------------
		// Stage 1 : Exponent calculation
		// -----------------------------------
		if (CTRL == ADD | CTRL == SUB) begin
			ADDNORM <= 8'b0;
			EXPCIN  <= 1'b1;
		end else begin			// for MUL
			ADDNORM <= 8'b10000001;
			EXPCIN  <= 1'b0;
		end
		
		// -----------------------------------
		// Stage 2 : Shifting
		// -----------------------------------
		if (CTRL1 == ADD | CTRL1 == SUB) begin			
			// Deciding which to be shifted					
			if (EXPCAL0[7] == 1'b0) begin			// exp(A) > exp(B), shift B to right
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
				NORM_MULSHIFT <= 7'bx;
				EXPONENT <= 8'b0;
			end else begin
				NORM_MULSHIFT <= 7'bx;
				EXPONENT <= EXPSRES;
			end
		end else if (CTRL3 == MUL) begin
			if (WML5_OUT[24] == 1'b0) begin
				// exponent is exponent
				NORM_MULSHIFT <= 7'bx;
				EXPONENT <= EXPCARRY1;
			end else begin
				// add 1 to exponent
				NORM_MULSHIFT <= 7'b1;
				EXPONENT <= EXPSRES;
			end
		end else begin
			NORM_MULSHIFT <= 7'bx;
			EXPONENT <= EXPSRES;			// TO BE CHANGED!!!
		end
	end
	
	
	// Let ADD be 3'b000
	always@(posedge FPUCLK) begin		
		// -----------------------------------
		// Stage 1 : Exponent calculation
		// -----------------------------------
		
		if (CTRL == ADD | CTRL == SUB | CTRL == MUL) begin
			APP0    <= {1'b1,A[22:0]};
			BPP0    <= {1'b1,B[22:0]};
			ASIGN0  <= A[31];
			BSIGN0  <= B[31];
		
			EXPCAL0 <= EXPCAL_w;
			CTRL1	  <= CTRL;
		end
		
		if (EXPCAL_w == 8'b0) begin
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
			if (EXPCAL0[7] == 1'b0) begin			// exp(A) > exp(B), shift B to right
				APP1      <= APP0;
				BPP1      <= SHIFTOUT_w;
				EXPCARRY0  <= A[30:23]; 
			end else begin									// exp(B) > exp(A), shift A to right
				APP1  	 <= SHIFTOUT_w;
				BPP1      <= BPP0;
				EXPCARRY0  <= B[30:23];					
			end
		end else if (CTRL1 == MUL) begin
			CTRL2  <= CTRL1;
			ASIGN1 <= ASIGN0;
			BSIGN1 <= BSIGN0;
			EXPCARRY0 <= EXPCAL0;
			
			RML1_12   <= WML1_12;
			RML1_34   <= WML1_34;
			RML1_56   <= WML1_56;
			RML1_78   <= WML1_78;
			RML1_910  <= WML1_910;
			RML1_1112 <= WML1_1112;
			RML1_1314 <= WML1_1314;
			RML1_1516 <= WML1_1516;
			RML1_1718 <= WML1_1718;
			RML1_1920 <= WML1_1920;
			RML1_2122 <= WML1_2122;
			RML1_2324 <= WML1_2324;
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
		end else if (CTRL == MUL) begin
			CTRL3 <= CTRL2;
			EXPCARRY1 <= EXPCARRY0;
			SIGN <= ASIGN1 ^ BSIGN1;
			
			RML3_12345678         <= WML3_12345678;
			RML3_910111213141516  <= WML3_910111213141516;
			RML3_1718192021222324 <= WML3_1718192021222324;
		end
		
		
		// -----------------------------------
		// Stage 4 : Sign resolution
		// -----------------------------------
		if ((CTRL3 == ADD)|(CTRL3 == SUB)) begin
			OUT <= {SIGN, EXPONENT, NORMOUT};
		end else if (CTRL == MUL) begin
			if (WML5_OUT[24] == 1'b0) begin
				OUT <= {SIGN, EXPONENT, WML5_OUT[22:0]};
			end else begin
				OUT <= {SIGN, EXPONENT, WML5_OUT[23:1]};
			end
		end
	end
endmodule 