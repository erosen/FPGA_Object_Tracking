//Converts RGB color to Grayscale

module RGB2GRAY(iRed,
				iGreen,
				iBlue,
				oGray,
				);


input	[11:0]	iRed;
input	[11:0]	iGreen;
input	[11:0]	iBlue;

output	[11:0]	oGray;


//oGray=0.299R+0.587G+0.114B;
assign	oGray	=	(iRed >> 2) + (iRed >> 5) + 
						(iGreen >> 1) + (iGreen >> 4) + 
						(iBlue >> 4) + (iBlue >> 5);

endmodule
