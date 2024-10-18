module mul_l1(
		input  [23:0] A, B,
		output [2:0]  OUT12,
		output [4:0]  OUT34,
		output [6:0]  OUT56,
		output [8:0]  OUT78,
		output [10:0] OUT910,
		output [12:0] OUT1112,
		output [14:0] OUT1314,
		output [16:0] OUT1516,
		output [18:0] OUT1718,
		output [20:0] OUT1920,
		output [22:0] OUT2122,
		output [24:0] OUT2324
	);
	
	wire W1;
	wire [1:0] W2;
	wire [2:0] W3;
	wire [3:0] W4;
	wire [4:0] W5;
	wire [5:0] W6;
	wire [6:0] W7;
	wire [7:0] W8;
	wire [8:0] W9;
	wire [9:0] W10;
	wire [10:0] W11;
	wire [11:0] W12;
	wire [12:0] W13;
	wire [13:0] W14;
	wire [14:0] W15;
	wire [15:0] W16;
	wire [16:0] W17;
	wire [17:0] W18;
	wire [18:0] W19;
	wire [19:0] W20;
	wire [20:0] W21;
	wire [21:0] W22;
	wire [22:0] W23;
	wire [23:0] W24;
	
	assign W1  = (B[0]  == 1'b1) ? A[23]    : 1'b0;
	assign W2  = (B[1]  == 1'b1) ? A[23:22] : 2'b0;
	assign W3  = (B[2]  == 1'b1) ? A[23:21] : 3'b0;
	assign W4  = (B[3]  == 1'b1) ? A[23:20] : 4'b0;
	assign W5  = (B[4]  == 1'b1) ? A[23:19] : 5'b0;
	assign W6  = (B[5]  == 1'b1) ? A[23:18] : 6'b0;
	assign W7  = (B[6]  == 1'b1) ? A[23:17] : 7'b0;
	assign W8  = (B[7]  == 1'b1) ? A[23:16] : 8'b0;
	assign W9  = (B[8]  == 1'b1) ? A[23:15] : 9'b0;
	assign W10 = (B[9]  == 1'b1) ? A[23:14] : 10'b0;
	assign W11 = (B[10] == 1'b1) ? A[23:13] : 11'b0;
	assign W12 = (B[11] == 1'b1) ? A[23:12] : 12'b0;
	assign W13 = (B[12] == 1'b1) ? A[23:11] : 13'b0;
	assign W14 = (B[13] == 1'b1) ? A[23:10] : 14'b0;
	assign W15 = (B[14] == 1'b1) ? A[23:9]  : 15'b0;
	assign W16 = (B[15] == 1'b1) ? A[23:8]  : 16'b0;
	assign W17 = (B[16] == 1'b1) ? A[23:7]  : 17'b0;
	assign W18 = (B[17] == 1'b1) ? A[23:6]  : 18'b0;
	assign W19 = (B[18] == 1'b1) ? A[23:5]  : 19'b0;
	assign W20 = (B[19] == 1'b1) ? A[23:4]  : 20'b0;
	assign W21 = (B[20] == 1'b1) ? A[23:3]  : 21'b0;
	assign W22 = (B[21] == 1'b1) ? A[23:2]  : 22'b0;
	assign W23 = (B[22] == 1'b1) ? A[23:1]  : 23'b0;
	assign W24 = (B[23] == 1'b1) ? A[23:0]  : 24'b0;
	
	// line 1, 2
	hcla l1_00(.A({1'b0,W1}), .B(W2), .CIN(1'b0), .COUT(OUT12[2]), .S(OUT12[1:0]));
	
	// line 3, 4	
	cla  l1_10(.A({1'b0,W3}), .B(W4), .CIN(1'b0), .COUT(OUT34[4]), .S(OUT34[3:0]));
	
	// line 5, 6
	wire CARRY56;
	cla  l1_20(.A(W5[3:0]), .B(W6[3:0]), .CIN(1'b0), .COUT(CARRY56), .S(OUT56[3:0]));
	hcla l1_21(.A({1'b0,W5[4]}), .B(W6[5:4]), .CIN(CARRY56), .COUT(OUT56[6]), .S(OUT56[5:4]));
	
	// line 7, 8
	wire CARRY78;
	cla  l1_30(.A(W7[3:0]), .B(W8[3:0]), .CIN(1'b0), .COUT(CARRY78), .S(OUT78[3:0]));
	cla  l1_31(.A({1'b0,W7[6:4]}), .B(W8[7:4]), .CIN(CARRY78), .COUT(OUT78[8]), .S(OUT78[7:4]));
	
	// line 9, 10
	wire CARRY910_0, CARRY910_1;
	cla  l1_40(.A(W9[3:0]), .B(W10[3:0]), .CIN(1'b0), .COUT(CARRY910_0), .S(OUT910[3:0]));
	cla  l1_41(.A(W9[7:4]), .B(W10[7:4]), .CIN(CARRY910_0), .COUT(CARRY910_1), .S(OUT910[7:4]));
	hcla l1_42(.A({1'b0,W9[8]}), .B(W10[9:8]), .CIN(CARRY910_1), .COUT(OUT910[10]), .S(OUT910[9:8]));
	
	// line 11, 12
	wire CARRY1112_0, CARRY1112_1;
	cla  l1_50(.A(W11[3:0]), .B(W12[3:0]), .CIN(1'b0), .COUT(CARRY1112_0), .S(OUT1112[3:0]));
	cla  l1_51(.A(W11[7:4]), .B(W12[7:4]), .CIN(CARRY1112_0), .COUT(CARRY1112_1), .S(OUT1112[7:4]));
	cla  l1_52(.A({1'b0,W11[10:8]}), .B(W12[11:8]), .CIN(CARRY1112_1), .COUT(OUT1112[12]), .S(OUT1112[11:8]));

	// line 13,14
	wire CARRY1314_0, CARRY1314_1, CARRY1314_2;
	cla  l1_60(.A(W13[3:0]), .B(W14[3:0]), .CIN(1'b0), .COUT(CARRY1314_0), .S(OUT1314[3:0]));
	cla  l1_61(.A(W13[7:4]), .B(W14[7:4]), .CIN(CARRY1314_0), .COUT(CARRY1314_1), .S(OUT1314[7:4]));
	cla  l1_62(.A(W13[11:8]), .B(W14[11:8]), .CIN(CARRY1314_1), .COUT(CARRY1314_2), .S(OUT1314[11:8]));
	hcla l1_63(.A({1'b0,W13[12]}), .B(W14[13:12]), .CIN(CARRY1314_2), .COUT(OUT1314[14]), .S(OUT1314[13:12]));
	
	// line 15, 16
	wire CARRY1516_0, CARRY1516_1, CARRY1516_2;
	cla  l1_70(.A(W15[3:0]), .B(W16[3:0]), .CIN(1'b0), .COUT(CARRY1516_0), .S(OUT1516[3:0]));
	cla  l1_71(.A(W15[7:4]), .B(W16[7:4]), .CIN(CARRY1516_0), .COUT(CARRY1516_1), .S(OUT1516[7:4]));
	cla  l1_72(.A(W15[11:8]), .B(W16[11:8]), .CIN(CARRY1516_1), .COUT(CARRY1516_2), .S(OUT1516[11:8]));
	cla  l1_73(.A({1'b0,W15[14:12]}), .B(W16[15:12]), .CIN(CARRY1516_2), .COUT(OUT1516[16]), .S(OUT1516[15:12]));
	
	// line 17, 18
	wire CARRY1718_0, CARRY1718_1, CARRY1718_2, CARRY1718_3;
	cla  l1_80(.A(W17[3:0]), .B(W18[3:0]), .CIN(1'b0), .COUT(CARRY1718_0), .S(OUT1718[3:0]));
	cla  l1_81(.A(W17[7:4]), .B(W18[7:4]), .CIN(CARRY1718_0), .COUT(CARRY1718_1), .S(OUT1718[7:4]));
	cla  l1_82(.A(W17[11:8]), .B(W18[11:8]), .CIN(CARRY1718_1), .COUT(CARRY1718_2), .S(OUT1718[11:8]));
	cla  l1_83(.A(W17[15:12]), .B(W18[15:12]), .CIN(CARRY1718_2), .COUT(CARRY1718_3), .S(OUT1718[15:12]));
	hcla l1_84(.A({1'b0,W17[16]}), .B(W18[17:16]), .CIN(CARRY1718_3), .COUT(OUT1718[18]), .S(OUT1718[17:16]));
	
	// line 19, 20
	wire CARRY1920_0, CARRY1920_1, CARRY1920_2, CARRY1920_3;
	cla  l1_90(.A(W19[3:0]), .B(W20[3:0]), .CIN(1'b0), .COUT(CARRY1920_0), .S(OUT1920[3:0]));
	cla  l1_91(.A(W19[7:4]), .B(W20[7:4]), .CIN(CARRY1920_0), .COUT(CARRY1920_1), .S(OUT1920[7:4]));
	cla  l1_92(.A(W19[11:8]), .B(W20[11:8]), .CIN(CARRY1920_1), .COUT(CARRY1920_2), .S(OUT1920[11:8]));
	cla  l1_93(.A(W19[15:12]), .B(W20[15:12]), .CIN(CARRY1920_2), .COUT(CARRY1920_3), .S(OUT1920[15:12]));
	cla  l1_94(.A({1'b0,W19[18:16]}), .B(W20[19:16]), .CIN(CARRY1920_3), .COUT(OUT1920[20]), .S(OUT1920[19:16]));
	
	// line 21, 22
	wire CARRY2122_0, CARRY2122_1, CARRY2122_2, CARRY2122_3, CARRY2122_4;
	cla  l1_100(.A(W21[3:0]), .B(W22[3:0]), .CIN(1'b0), .COUT(CARRY2122_0), .S(OUT2122[3:0]));
	cla  l1_101(.A(W21[7:4]), .B(W22[7:4]), .CIN(CARRY2122_0), .COUT(CARRY2122_1), .S(OUT2122[7:4]));
	cla  l1_102(.A(W21[11:8]), .B(W22[11:8]), .CIN(CARRY2122_1), .COUT(CARRY2122_2), .S(OUT2122[11:8]));
	cla  l1_103(.A(W21[15:12]), .B(W22[15:12]), .CIN(CARRY2122_2), .COUT(CARRY2122_3), .S(OUT2122[15:12]));
	cla  l1_104(.A(W21[19:16]), .B(W22[19:16]), .CIN(CARRY2122_3), .COUT(CARRY2122_4), .S(OUT2122[19:16]));
	hcla l1_105(.A({1'b0,W21[20]}), .B(W22[21:20]), .CIN(CARRY2122_4), .COUT(OUT2122[22]), .S(OUT2122[21:20]));
	
	wire CARRY2324_0, CARRY2324_1, CARRY2324_2, CARRY2324_3, CARRY2324_4;
	cla  l1_110(.A(W23[3:0]), .B(W24[3:0]), .CIN(1'b0), .COUT(CARRY2324_0), .S(OUT2324[3:0]));
	cla  l1_111(.A(W23[7:4]), .B(W24[7:4]), .CIN(CARRY2324_0), .COUT(CARRY2324_1), .S(OUT2324[7:4]));
	cla  l1_112(.A(W23[11:8]), .B(W24[11:8]), .CIN(CARRY2324_1), .COUT(CARRY2324_2), .S(OUT2324[11:8]));
	cla  l1_113(.A(W23[15:12]), .B(W24[15:12]), .CIN(CARRY2324_2), .COUT(CARRY2324_3), .S(OUT2324[15:12]));
	cla  l1_114(.A(W23[19:16]), .B(W24[19:16]), .CIN(CARRY2324_3), .COUT(CARRY2324_4), .S(OUT2324[19:16]));
	cla  l1_115(.A({1'b0,W23[22:20]}), .B(W24[23:20]), .CIN(CARRY2324_4), .COUT(OUT2324[24]), .S(OUT2324[23:20]));
endmodule 