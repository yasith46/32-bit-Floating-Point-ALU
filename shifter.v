module shifter(
		input  [23:0] IN,
		input  [7:0]  BY,
		output reg [23:0] OUT
	);
	
	always@(IN or BY) begin
		if (BY[7] == 1'b0) begin	// When BY is > 0
			OUT = IN << BY;
		end else begin					// When BY is < 0
			OUT = IN >> (~(BY) + 1'b1);
		end
	end
endmodule 