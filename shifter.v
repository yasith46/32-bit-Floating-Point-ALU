module shifter(
		input  [23:0] IN,
		input  [7:0]  BY,
		output reg [23:0] OUT
	);
	
	wire COUT_INT;
	wire [7:0] BY_COMPL;
	
	// Calculating the absolute
	
	cla cla_int_sh0(
		.A(~BY[3:0]),
		.B(4'b1),
		.CIN(1'b1),
		.COUT(COUT_INT),
		.S(BY_COMPL[3:0])
	);
	
	cla cla_int_sh1(
		.A(~BY[7:4]),
		.B(4'b0),
		.CIN(COUT_INT),
		.COUT(),
		.S(BY_COMPL[7:4])
	);
	
	always@(*) begin
		if (BY[7] == 1'b0) begin	// When BY is > 0
			OUT = IN >> BY;
		end else begin					// When BY is < 0
			OUT = IN >> BY_COMPL;
		end
	end
endmodule 