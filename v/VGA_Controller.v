// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	VGA_Controller
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN Peli Li:| 22/07/2010:| Initial Revision
// --------------------------------------------------------------------

module	VGA_Controller(	//	Host Side
						iGrayMem1,
						iGrayMem2,
						iTrackMode,
						oRequest,
						//	VGA Side
						oVGA_R,
						oVGA_G,
						oVGA_B,
						oVGA_H_SYNC,
						oVGA_V_SYNC,
						oVGA_SYNC,
						oVGA_BLANK,

						//	Control Signal
						iCLK,
						iRST_N,
						iZOOM_MODE_SW
							);

//	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	96;
parameter	H_SYNC_BACK	=	48;
parameter	H_SYNC_ACT	=	640;	
parameter	H_SYNC_FRONT=	16;
parameter	H_SYNC_TOTAL=	800;

//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	2;
parameter	V_SYNC_BACK	=	33;
parameter	V_SYNC_ACT	=	480;	
parameter	V_SYNC_FRONT=	10;
parameter	V_SYNC_TOTAL=	525; 


//	Start Offset
parameter	X_START		=	H_SYNC_CYC+H_SYNC_BACK;
parameter	Y_START		=	V_SYNC_CYC+V_SYNC_BACK;
//	Host Side
input		[9:0]	iGrayMem1;
input		[9:0]	iGrayMem2;
input 	[3:0] iTrackMode;
output	reg			oRequest;
//	VGA Side
output	reg	[9:0]	oVGA_R;
output	reg	[9:0]	oVGA_G;
output	reg	[9:0]	oVGA_B;
output	reg			oVGA_H_SYNC;
output	reg			oVGA_V_SYNC;
output	reg			oVGA_SYNC;
output	reg			oVGA_BLANK;

wire		[9:0]	mVGA_R;
wire		[9:0]	mVGA_G;
wire		[9:0]	mVGA_B;
reg					mVGA_H_SYNC;
reg					mVGA_V_SYNC;
wire				mVGA_SYNC;
wire				mVGA_BLANK;

//	Control Signal
input				iCLK;
input				iRST_N;
input 				iZOOM_MODE_SW;

//	Internal Registers and Wires
reg		[12:0]		H_Cont;
reg		[12:0]		V_Cont;

wire	[12:0]		v_mask;



assign v_mask = 13'd0 ;//iZOOM_MODE_SW ? 13'd0 : 13'd26;

////////////////////////////////////////////////////////

assign	mVGA_BLANK	=	mVGA_H_SYNC & mVGA_V_SYNC;
assign	mVGA_SYNC	=	1'b0;

assign	mVGA_R	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT &&
						V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT )
						?	RedValue :	0;
assign	mVGA_G	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT &&
						V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT )
						?	GrayValue :	0;
assign	mVGA_B	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT &&
						V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT )
						?	GrayValue :	0;
//						
reg [9:0] GrayValue;
reg [9:0] RedValue;
//reg boxValue;
reg grayChange;
reg redChange;

reg [18:0] indexCount;

parameter indexCountMax = 307200;
parameter pixLength = 640;
parameter pixHeight = 480;
parameter distanceThresh = 20;
parameter densityThresh = 10;

reg motionArray2D [479:0][639:0];
reg binaryMotionArray [307199:0];
reg rowMotionArray [307199:0];
reg continousRow;

integer i;

parameter windowSize = 32;
parameter minDensity = 12;
parameter GrayChangeThreshold = 50;


// threshholding and black differencve generation
always@(posedge iCLK)
begin

	if (iGrayMem1 > iGrayMem2)
		begin
			grayChange =  ((iGrayMem1 - iGrayMem2) > GrayChangeThreshold);
		end
	
	else
		begin
			grayChange =  ((iGrayMem2 - iGrayMem1) > GrayChangeThreshold);
		end
end
		



// BROKEN Change display mode vs switches

always@(grayChange or iTrackMode)
begin
/*
		case (iTrackMode)
					
			4'b0001 : // display only tracking data 
				begin
					GrayValue =  0;
					RedValue  =  grayChange ? 1023 : 0;
				end
			
			4'b0010 : // display tracking data on top of image
				begin
				*/
					GrayValue =  grayChange ? 0 : iGrayMem1;
					RedValue  =  grayChange ? 1023 : iGrayMem1;
				/*
				end
			
			4'b0100 : // display tracking data in cyan
				begin
					GrayValue =  grayChange ? 1023 : 0;
					RedValue  =  0;
				end
				
			default : // display camera image 
				begin
					GrayValue =  iGrayMem1;
					RedValue  =  iGrayMem1;
				end
		endcase
*/
end


// Index Counter
/*
always@(grayChange)
begin

	indexCount = 0;

	while ( indexCount < indexCountMax )
	begin
		indexCount = indexCount + 1;
	end

end
*/

// Index Counter
always@(H_Cont or V_Cont)
begin

	if ((	H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT 
			&& V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT ))
	begin
	
		if (indexCount < indexCountMax)
		
			indexCount = indexCount + 1;
			
		else
		
			indexCount = 0;
	
	end
end



// sets binaryMotionArray to a 0 or 1 based on the whether or not motion
// index of binaryMotionArray is based on indexCount 
always@(indexCount)
begin
	binaryMotionArray[indexCount] = grayChange;
end

always@(negedge indexCount)
begin 
	if(indexCount >= distanceThresh)
	begin
		continousRow = 0;
		
		for( i = 0; i < distanceThresh; i = i + 1 )
		begin
			continousRow = continousRow + binaryMotionArray[indexCount - i];
		end
		
		if(continousRow >= densityThresh)
		begin
		
			for( i = 0; i < distanceThresh; i = i + 1 )
			begin
				rowMotionArray[indexCount - i] = 1;
			end
		
		end
			
	end
end
	

always@(posedge iCLK or negedge iRST_N)
	begin
		if (!iRST_N)
			begin
				oVGA_R <= 0;
				oVGA_G <= 0;
                oVGA_B <= 0;
				oVGA_BLANK <= 0;
				oVGA_SYNC <= 0;
				oVGA_H_SYNC <= 0;
				oVGA_V_SYNC <= 0; 
			end
		else
			begin
				oVGA_R <= mVGA_R;
				oVGA_G <= mVGA_G;
            oVGA_B <= mVGA_B;
				oVGA_BLANK <= mVGA_BLANK;
				oVGA_SYNC <= mVGA_SYNC;
				oVGA_H_SYNC <= mVGA_H_SYNC;
				oVGA_V_SYNC <= mVGA_V_SYNC;				
			end               
	end



//	Pixel LUT Address Generator
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	oRequest	<=	0;
	else
	begin
		if(	H_Cont>=X_START-2 && H_Cont<X_START+H_SYNC_ACT-2 &&
			V_Cont>=Y_START && V_Cont<Y_START+V_SYNC_ACT )
		oRequest	<=	1;
		else
		oRequest	<=	0;
	end
end

//	H_Sync Generator, Ref. 40 MHz Clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
		mVGA_H_SYNC	<=	0;
	end
	else
	begin
		//	H_Sync Counter
		if( H_Cont < H_SYNC_TOTAL )
		H_Cont	<=	H_Cont+1;
		else
		H_Cont	<=	0;
		//	H_Sync Generator
		if( H_Cont < H_SYNC_CYC )
		mVGA_H_SYNC	<=	0;
		else
		mVGA_H_SYNC	<=	1;
	end
end

//	V_Sync Generator, Ref. H_Sync
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
		mVGA_V_SYNC	<=	0;
	end
	else
	begin
		//	When H_Sync Re-start
		if(H_Cont==0)
		begin
			//	V_Sync Counter
			if( V_Cont < V_SYNC_TOTAL )
			V_Cont	<=	V_Cont+1;
			else
			V_Cont	<=	0;
			//	V_Sync Generator
			if(	V_Cont < V_SYNC_CYC )
			mVGA_V_SYNC	<=	0;
			else
			mVGA_V_SYNC	<=	1;
		end
	end
end

endmodule
