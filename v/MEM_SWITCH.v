 // Memory Multiplexer
module MEM_SWITCH	(iGray,
						iFrameCount,
						oGray1,
						oGray2
						);

input		[11:0]	iGray;
input					iFrameCount;

output	[11:0]	oGray1;
output	[11:0]	oGray2;

reg		[11:0] tempGray1;
reg 		[11:0] tempGray2;

assign oGray1 = tempGray1;
assign oGray2 = tempGray2;

always@(iFrameCount)
begin

	if(iFrameCount)
	
		tempGray1 = iGray;
		
	else 
	
		tempGray2 = iGray;
	
end


endmodule
