module project(
	CLOCK_50,
	CLOCK2_50,
	CLOCK3_50,
	KEY,
	SW,
	VGA_B,
	VGA_BLANK_N,
	VGA_CLK,
	VGA_G,
	VGA_HS,
	VGA_R,
	VGA_SYNC_N,
	VGA_VS 
);
input CLOCK_50;
input CLOCK2_50;
input CLOCK3_50;
input [3:0] KEY;
input [17:0] SW;
output [7:0] VGA_B;
output VGA_BLANK_N;
output VGA_CLK;
output [7:0] VGA_G;
output	VGA_HS;
output [7:0] VGA_R;
output VGA_SYNC_N;
output VGA_VS;
reg	aresetPll = 0;
wire pixelClock;
wire [10:0] XPixelPosition;
wire [10:0] YPixelPosition; 
reg	[7:0] redValue;
reg	[7:0] greenValue;
reg	[7:0] blueValue;
reg	[2:0] movement = 0;
reg	[3:0] tool = 0;
reg [10:0] r = 10;
reg [10:0] speed = 1;
reg [10:0] P1_paddle_len = 125;
reg [10:0] P2_paddle_len = 125;
reg [10:0] P1_paddle_speed = 5;
reg [10:0] P2_paddle_speed = 5;
reg [20:0] slowClockCounter = 0;
wire slowClock;
reg [20:0] fastClockCounter = 0;
wire fastClock;
reg	[10:0] XDotPosition = 500;
reg	[10:0] YDotPosition = 500; 
reg	[10:0] P1x = 225;
reg	[10:0] P1y = 500;
reg	[10:0] P2x = 1030;
reg	[10:0] P2y = 500;
reg [3:0] P1Score = 0;
reg	[3:0] P2Score = 0;
reg flag =1;
reg	[2:0] printer = 0;
wire [9:0] randX;
wire [9:0] randY;
reg [9:0] itemX = 640;
reg [9:0] itemY = 512;
reg [27:0] clock;
wire [3:0] rtool;
wire [7:0] color1;
wire [7:0] color2;
wire [7:0] color3;
reg [7:0] col1;
reg [7:0] col2;
reg [7:0] col3;
reg [3:0] randomtool = 2;
reg [1:0] drawItem;

assign VGA_BLANK_N = 1'b1;
assign VGA_SYNC_N = 1'b1;			
assign VGA_CLK = pixelClock;


RandomPoint ran(VGA_CLK, randX, randY);
RandomTool rant(VGA_CLK, rtool, color1, color2, color3);

assign slowClock = slowClockCounter[16];

//Set the counter with slow speed by the CLOCK_50
always@ (posedge CLOCK_50)
begin
	slowClockCounter <= slowClockCounter + 1;
end

//Set the counter with fast speed by the CLOCK_50
assign fastClock = fastClockCounter[17];

always@ (posedge CLOCK_50)
begin
	fastClockCounter <= fastClockCounter + 1;
end

//it controls the left paddle.
always@(posedge fastClock)
begin
	if (SW[0] == 1'b1 && flag == 1) 
		begin
			if (KEY[2] == 1'b0 && KEY[3] == 1'b0) 
				P1y <= P1y;
			else if (KEY[2] == 1'b0)
				begin
					if (P1y+P1_paddle_len >= 895)
						P1y <= 895-P1_paddle_len;
					else
						P1y <= P1y + P1_paddle_speed;
				end
			else if (KEY[3] == 1'b0)
				begin
					if(P1y <= 125)
						P1y <= 125;
					else
						P1y <= P1y - P1_paddle_speed;
				end
		end
	
	else if (SW[0] == 1'b0)
		P1y <= 500;
end

//it controls the right paddle
always@(posedge fastClock)
	begin
		if (SW[0] == 1'b1 && flag ==1) 
			begin
				if (KEY[0] == 1'b0 && KEY[1] == 1'b0) 
					P2y <= P2y;
				else if (KEY[0] == 1'b0) begin
					if(P2y+P2_paddle_len >= 895)
						P2y <= 895-P2_paddle_len;
					else
					P2y <= P2y + P2_paddle_speed;
				end
				else if (KEY[1] == 1'b0) begin
					if(P2y <= 125)
						P2y <= 125;
					else
						P2y <= P2y - P2_paddle_speed;
				end
		end
	else if (SW[0] == 1'b0)
		P2y <= 500;
	end

//It controls the movement of the ball
always@(posedge slowClock)
begin
	if (SW[0] == 1'b1 && flag ==1)
		begin
			clock <= clock + 1;
			printer <= 0;
			case(movement)
				//Change the speed of ball by speed reg
				0:		begin
							XDotPosition <= XDotPosition + speed;
							YDotPosition <= YDotPosition - speed;
						end
				1:		begin
							XDotPosition <= XDotPosition + speed;
							YDotPosition <= YDotPosition + speed;
						end
				2:		begin
							XDotPosition <= XDotPosition - speed;
							YDotPosition <= YDotPosition + speed;
						end
				3:		begin
							XDotPosition <= XDotPosition - speed;
							YDotPosition <= YDotPosition - speed;
						end
				default:	begin
								XDotPosition <= XDotPosition + speed;
								YDotPosition <= YDotPosition - speed;
							end
			endcase
			
			//It runs the changes of ball or paddle randomly
			//When the ball meet the tool random point
			case(tool)
				0:		begin 
							r <= 10;
							P1_paddle_len <= 125;
							P2_paddle_len <= 125;
							speed = 1;
							P1_paddle_speed = 5;
							P2_paddle_speed = 5;
							drawItem <= 1;
						end
				1:		begin
							r <= 20;
							tool <= clock == 5000 ? 0:tool;
						end
				2:		begin
							P1_paddle_len <= 200;
							tool <= clock == 5000 ? 0:tool;
						end
				3:		begin
							P2_paddle_len <= 200;
							tool <= clock == 5000 ? 0:tool;
						end
				4: 		begin
							speed = 2;
							tool <= clock == 5000 ? 0:tool;
						end
				5:		begin
							P1_paddle_len <= 50;
							tool <= clock == 5000 ? 0:tool;
						end
				6:		begin
							P2_paddle_len <= 50;
							tool <= clock == 5000 ? 0:tool;
						end
				7:		begin
							P1_paddle_speed <= 10;
							tool <= clock == 5000 ? 0:tool;
						end
				8:		begin
							P2_paddle_speed <= 10;
							tool <= clock == 5000 ? 0:tool;
						end
				9:		begin
							P1_paddle_speed <= 3;
							tool <= clock == 5000 ? 0:tool;
						end
				10:		begin
							P2_paddle_speed <= 3;
							tool <= clock == 5000 ? 0:tool;
						end
				default:	begin
							r <= 10;
							P1_paddle_len <= 125;
							P2_paddle_len <= 125;
							speed = 1;
							P1_paddle_speed = 5;
							P2_paddle_speed = 5;
							drawItem <= 1;
						end
			endcase
			
			//(XDotPosition, YDotPosition) represents the coordinate of the ball
			// when the ball is in some range, change the movement.
			if(YDotPosition - r <= 128 && movement == 0)
				movement = 1;
			else if (YDotPosition - r <= 128 && movement == 3)
				movement = 2;
			else if (YDotPosition + r >= 896 && movement == 1)
				movement = 0;
			else if (YDotPosition + r >= 896 && movement == 2)
				movement = 3;
			else if (XDotPosition - r <= P1x+10 && XDotPosition - r >= P1x+7 && YDotPosition > P1y && YDotPosition < P1y+P1_paddle_len &&  movement == 2)//bounce left paddle from SW
				movement = 1;
			else if (XDotPosition - r <= P1x+10 && XDotPosition - r >= P1x+7 && YDotPosition > P1y && YDotPosition < P1y+P1_paddle_len &&  movement == 3)//bounce left paddle from NW
				movement = 0;
			else if (XDotPosition + r >= P2x && XDotPosition + r <= P2x + 3 && YDotPosition > P2y && YDotPosition < P2y+P2_paddle_len &&  movement == 1)//bounce right paddle from SE 
				movement = 2;
			else if (XDotPosition + r >= P2x && XDotPosition + r <= P2x + 3 && YDotPosition > P2y && YDotPosition < P2y+P2_paddle_len &&  movement == 0)//bounce right paddle from NE
				movement = 3;
			else if (XDotPosition + r >= itemX - r && XDotPosition - r <= itemX + r && YDotPosition + r >= itemY - r && YDotPosition - r <= itemY + r && drawItem == 1)// ball hit the item
				begin
				//Pick the tool randomly and make the change randomly
					clock <= 0;
					if (randomtool == 2 && (movement == 2 || movement == 3))
						tool <= 3;
					else if (randomtool == 3 && (movement == 1 || movement == 0))
						tool <= 2;
					else if (randomtool == 5 && (movement == 1 || movement == 0))
						tool <= 6;
					else if (randomtool == 6 && (movement == 2 || movement == 3))
						tool <= 5;
					else if (randomtool == 7 && (movement == 2 || movement == 3))
						tool <= 8;
					else if (randomtool == 8 && (movement == 1 || movement == 0))
						tool <= 7;
					else if (randomtool == 9 && (movement == 1 || movement == 0))
						tool <= 10;
					else if (randomtool == 10 && (movement == 2 || movement == 3))
						tool <= 9;
					else
						tool <= randomtool;
						
					itemX <= randX;
					itemY <= randY;
					randomtool <= rtool;
					drawItem <= 0;
				end
			else if (XDotPosition - r <= 160)
				begin
					P2Score = P2Score + 1;
					XDotPosition <= 640;
					YDotPosition <= 512;
				end
			else if (XDotPosition + r >= 1120)
				begin
					P1Score = P1Score + 1;
					XDotPosition <= 640;
					YDotPosition <= 512;
				end
				
			if(P1Score == 10 || P2Score ==10)
				begin
					flag <= 0;
					if (P1Score == 10)
						printer <= 1;
					else
						printer <= 2;
				end
		end
	
	//Use SW[0] to reset the game
	else if (SW[0] == 0)
		begin
			XDotPosition <= 640;
			YDotPosition <= 512;
			P1Score <= 0;
			P2Score <= 0;
			tool <= 0;
			drawItem <= 0;
			itemX <= randX;
			itemY <= randY;
			printer <= 3;
			flag <= 1;
		end
end

VGAFrequency VGAFreq (aresetPll, CLOCK_50, pixelClock);

VGAController VGAControl (pixelClock, redValue, greenValue, blueValue, VGA_R, VGA_G, VGA_B, VGA_VS, VGA_HS, XPixelPosition, YPixelPosition);

//VGA pattern and charactor display
always@ (posedge pixelClock)
begin		
		//Word1 on the top 
		if (XPixelPosition > 410 && XPixelPosition < 470 && YPixelPosition > 5 && YPixelPosition < 13)//row1
		begin
			if (printer == 1 || printer == 2 || printer == 3)
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
			end
			else
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
			end
		end
		else if (XPixelPosition > 410 && XPixelPosition < 470 && YPixelPosition > 46 && YPixelPosition < 54)//row2
		begin
			if (printer == 1 || printer == 2 || printer == 3)
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
			end
			else
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
			end
		end
		else if (XPixelPosition > 410 && XPixelPosition < 470 && YPixelPosition > 87 && YPixelPosition < 95)//row3
		begin
			if (printer == 3)
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
			end
			else
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
			end
		end
		else if (XPixelPosition > 410 && XPixelPosition < 418 && YPixelPosition > 5 && YPixelPosition < 50)//column 1
		begin
			if (printer == 1 || printer == 2 || printer == 3)
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
			end
			else
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
			end
		end
		else if (XPixelPosition > 410 && XPixelPosition < 418 && YPixelPosition > 50 && YPixelPosition < 95)//column 2
		begin
			if (printer == 1 || printer == 2)
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
			end
			else
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
			end
		end
		else if (XPixelPosition > 462 && XPixelPosition < 470 && YPixelPosition > 5 && YPixelPosition < 50)//column 5
		begin
			if (printer == 1 || printer == 2)
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
			end
			else
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
			end
		end
		else if (XPixelPosition > 462 && XPixelPosition < 470 && YPixelPosition > 50 && YPixelPosition < 95)//column 6
		begin
			if (printer == 3)
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
			end
			else
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
			end
		end

//Word2 on the top
		else if (XPixelPosition > 510 && XPixelPosition < 570 && YPixelPosition > 5 && YPixelPosition < 13)//row1
		begin
			if (printer == 2 || printer == 3)
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
			end
			else
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
			end
		end
		else if (XPixelPosition > 510 && XPixelPosition < 570 && YPixelPosition > 46 && YPixelPosition < 54)//row2
		begin
			if (printer == 2)
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
			end
			else
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
			end
		end
		else if (XPixelPosition > 510 && XPixelPosition < 570 && YPixelPosition > 87 && YPixelPosition < 95)//row3
		begin
			if (printer == 2)
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b11111111;
			greenValue <= 8'b11111111;
			end
			else
			begin
			redValue <= 8'b00000000; 
			blueValue <= 8'b00000000;
			greenValue <= 8'b00000000;
			end
		end
		else if (XPixelPosition > 510 && XPixelPosition < 518 && YPixelPosition > 50 && YPixelPosition < 95)//column 2
		begin
			if (printer == 2)
			begin
			redValue <= 8'b00000000; 
			