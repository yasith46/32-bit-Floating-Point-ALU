module normal(
			input  [23:0] IN,
			input  INOF,
			output reg [22:0] OUT,
			output reg [7:0] COUNT,
			output reg ZEROFLAG
	);
	
	always@(*) begin
		if (INOF == 1'b1) begin
			OUT   <= IN[23:1];	COUNT <= 8'b1;	  ZEROFLAG <= 1'b0;
		end else begin
			casez (IN)			
				24'b1???????????????????????:
					begin
						OUT <= IN[22:0];	COUNT <= 8'd0;  ZEROFLAG <= 1'b0;
					end 
					
				24'b01??????????????????????:
					begin
						OUT <= {IN[21:0], 1'b0};  COUNT <= -8'd1;  ZEROFLAG <= 1'b0;
					end
					
				24'b001?????????????????????:
					begin
						OUT <= {IN[20:0], 2'b0};  COUNT <= -8'd2;  ZEROFLAG <= 1'b0;
					end 
					
				24'b0001????????????????????:
					begin
						OUT <= {IN[19:0], 3'b0};  COUNT <= -8'd3;  ZEROFLAG <= 1'b0;
					end 
					
				24'b00001???????????????????:
					begin
						OUT <= {IN[18:0], 4'b0};  COUNT <= -8'd4;  ZEROFLAG <= 1'b0;
					end 
					
				24'b000001??????????????????:
					begin
						OUT <= {IN[17:0], 5'b0};  COUNT <= -8'd5;  ZEROFLAG <= 1'b0;
					end 
					
				24'b0000001?????????????????:
					begin
						OUT <= {IN[16:0], 6'b0};  COUNT <= -8'd6;  ZEROFLAG <= 1'b0;
					end 
					
				24'b00000001????????????????:
					begin
						OUT <= {IN[15:0], 7'b0};  COUNT <= -8'd7;  ZEROFLAG <= 1'b0;
					end 
					
				24'b000000001???????????????:
					begin
						OUT <= {IN[14:0], 8'b0};  COUNT <= -8'd8;  ZEROFLAG <= 1'b0;
					end 
					
				24'b0000000001??????????????:
					begin
						OUT <= {IN[13:0], 9'b0};  COUNT <= -8'd9;  ZEROFLAG <= 1'b0;
					end 
					
				24'b00000000001?????????????:
					begin
						OUT <= {IN[12:0], 10'b0};  COUNT <= -8'd10;  ZEROFLAG <= 1'b0;
					end 
					
				24'b000000000001????????????:
					begin
						OUT <= {IN[11:0], 11'b0};  COUNT <= -8'd11;  ZEROFLAG <= 1'b0;
					end 
					
				24'b0000000000001???????????:
					begin
						OUT <= {IN[10:0], 12'b0};  COUNT <= -8'd12;  ZEROFLAG <= 1'b0;
					end 
					
				24'b00000000000001??????????:
					begin
						OUT <= {IN[9:0], 13'b0};  COUNT <= -8'd13;  ZEROFLAG <= 1'b0;
					end 
					
				24'b000000000000001?????????:
					begin
						OUT <= {IN[8:0], 14'b0};  COUNT <= -8'd14;  ZEROFLAG <= 1'b0;
					end 
					
				24'b0000000000000001????????:
					begin
						OUT <= {IN[7:0], 15'b0};  COUNT <= -8'd15;  ZEROFLAG <= 1'b0;
					end 
					
				24'b00000000000000001???????:
					begin
						OUT <= {IN[6:0], 16'b0};  COUNT <= -8'd16;  ZEROFLAG <= 1'b0;
					end 
					
				24'b000000000000000001??????:
					begin
						OUT <= {IN[5:0], 17'b0};  COUNT <= -8'd17;  ZEROFLAG <= 1'b0;
					end 
					
				24'b0000000000000000001?????:
					begin
						OUT <= {IN[4:0], 18'b0};  COUNT <= -8'd18;  ZEROFLAG <= 1'b0;
					end 
					
				24'b00000000000000000001????:
					begin
						OUT <= {IN[3:0], 19'b0};  COUNT <= -8'd19;  ZEROFLAG <= 1'b0;
					end 
					
				24'b000000000000000000001???:
					begin
						OUT <= {IN[2:0], 20'b0};  COUNT <= -8'd20;  ZEROFLAG <= 1'b0;
					end 
					
				24'b0000000000000000000001??:
					begin
						OUT <= {IN[1:0], 21'b0};  COUNT <= -8'd21;  ZEROFLAG <= 1'b0;
					end 
					
				24'b00000000000000000000001?:
					begin
						OUT <= {IN[0], 22'b0};  COUNT <= -8'd22;  ZEROFLAG <= 1'b0;
					end
					
				24'b000000000000000000000001:
					begin
						OUT <= {23'b0};  COUNT <= -8'd23;  ZEROFLAG <= 1'b0;
					end
					
				default:
					begin
						OUT <= {23'b0};  COUNT <= -8'd24;  ZEROFLAG <= 1'b1;
					end 
			endcase
		end
	end
endmodule 