module twoscomp(
		input  [23:0] B,
		output [23:0] OUT
	);
	
	wire COUT0, COUT1, COUT2, COUT3, COUT4;
	
	twos_cla t0(.B(~B[ 3: 0]), .CIN(1'b1),   .COUT(COUT0), .S(OUT[3:0]));
	twos_cla t1(.B(~B[ 7: 4]), .CIN(COUT0),  .COUT(COUT1), .S(OUT[7:4]));
	twos_cla t2(.B(~B[11: 8]), .CIN(COUT1),  .COUT(COUT2), .S(OUT[11:8]));
	twos_cla t3(.B(~B[15:12]), .CIN(COUT2),  .COUT(COUT3), .S(OUT[15:12]));
	twos_cla t4(.B(~B[19:16]), .CIN(COUT3),  .COUT(COUT4), .S(OUT[19:16]));
	twos_cla t5(.B(~B[23:20]), .CIN(COUT4),  .COUT(),      .S(OUT[23:20]));
	
endmodule 