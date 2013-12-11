 // Memory Multiplexer
module MEM_SWITCH	(iGray,
						iFrameCount,
						iDVAL,
						oGray1,
						oGray2,
						oDVAL1,
						oDVAL2
						);

input		[11:0]	iGray;
input					iFrameCount;
input					iDVAL;

output	[11:0]	oGray1;
output	[11:0]	oGray2;
output 				oDVAL1;
output				oDVAL2;

reg		[11:0] tempGray1;
reg 		[11:0] tempGray2;

assign oGray1 = tempGray1;
assign oGray2 = tempGray2;

assign oDVAL1 = iFrameCount ? iDVAL : 0;
assign oDVAL2 = ~iFrameCount ? iDVAL : 0; 

always@(iFrameCount)
begin

	if(iFrameCount)
	
		tempGray1 = iGray;
		
	else 
	
		tempGray2 = iGray;
	
end


endmodule
