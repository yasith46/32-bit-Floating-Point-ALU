module divider(
		input  [23:0] A,B,
		input  CLK, REQ, RST,
		output reg [23:0] OUT,
		output reg READY
	);
	
	reg [23:0] DVS, QTT;
	reg [47:0] DVD_REM;
	reg [6:0]  COUNTER;
	wire [23:0] SUBOUT;
	
	cla_add cla_add0(
		.A(DVD_REM[47:24]),
		.B(DVS),
		.CIN(1'b1),
		.OUT(SUBOUT),
		.OF()
	);
	
	always@(posedge CLK) begin
			if (READY) begin
				if (REQ) begin			// Initialize if divider is requested
					READY <= 1'b0;
					DVS   <= B;
					QTT	<= 24'b0;
					DVD_REM <= {A, 24'b0};
					COUNTER <= 7'b0;
				end
			end else begin
				if (COUNTER != 7'd23) begin
					if (SUBOUT[23]) begin
						QTT <= QTT << 1;
						DVD_REM <= DVD_REM << 1;
					end else begin
						QTT <= {QTT[22:0], 1'b1};
						DVD_REM <= {SUBOUT[22:0], DVD_REM[23:0], 1'b0};
					end
					
					COUNTER <= COUNTER + 7'd1;
				end else begin
					COUNTER <= 7'b0;
					OUT <= {QTT[22:0], 1'b0};
					READY <= 1'b1;
				end
			end	
	end
endmodule 