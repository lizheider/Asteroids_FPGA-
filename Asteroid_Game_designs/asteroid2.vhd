-- Bouncing Ball Video 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY asteriod2 IS
   PORT(pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  Size_in 						: IN std_logic_vector(10 DOWNTO 0);
		  init_X_pos 					: IN std_logic_vector(10 DOWNTO 0);
		  init_X_vel, init_Y_vel	: IN std_logic_vector(10 DOWNTO 0);
        Vert_sync						: IN std_logic;
		  en								: IN std_logic;
		  reset							: IN std_logic;
		  clk 							: IN std_logic;
		  
		  off_edge						: OUT std_logic;
		  white			 				: OUT std_logic;
		  X								: OUT std_logic_vector(10 DOWNTO 0);
		  Y								: OUT std_logic_vector(10 DOWNTO 0);
		  W								: OUT std_logic_vector(10 DOWNTO 0);
		  H								: OUT std_logic_vector(10 DOWNTO 0));
END asteriod2;

architecture behavior of asteriod2 is  -- Video Display Signals
SIGNAL Ball_on, Direction								: std_logic; 
SIGNAL Ball_Y_motion, Ball_X_motion 				: std_logic_vector(10 DOWNTO 0);
SIGNAL X_COUNT, Y_COUNT									: std_logic_vector(10 DOWNTO 0);
SIGNAL Ball_Y_pos, Ball_X_pos							: std_logic_vector(10 DOWNTO 0);
SIGNAL init_Y_pos											: std_logic_vector(10 DOWNTO 0);
SIGNAL buffer_size										: std_logic_vector(10 DOWNTO 0);
SIGNAL Size													: std_logic_vector(10 DOWNTO 0);
BEGIN  
-- Colors for pixel data on video signal
buffer_size <= Size(9 downto 0) & '0'; --multiply size by 2 to get buffer size
init_Y_pos <= Size; 							--start asteriod in middle of buffer

white <= ball_on;

-- Assign outputs for collision dector
X <= Ball_X_pos;
Y <= Ball_Y_pos;
W <= Size;
H <= Size;

RGB_Display: Process (pixel_column, pixel_row) --(Ball_X_pos, Ball_Y_pos, pixel_column, pixel_row, Size)
BEGIN
 -- Set Ball_on ='1' to display ball
 IF (Ball_X_pos <= pixel_column + Size + buffer_size) AND
 	 (Ball_X_pos + Size >= pixel_column + buffer_size) AND
 	 (Ball_Y_pos <= pixel_row + Size + buffer_size) AND
 	 (Ball_Y_pos + Size >= pixel_row + buffer_size) THEN
 		Ball_on <= '1';
 	ELSE
 		Ball_on <= '0';
END IF;
END process RGB_Display;

Move_Ball: process (clk)
BEGIN 
	IF (reset = '0') THEN
		Ball_Y_pos <= Init_Y_pos;
		Ball_X_pos <= Init_X_pos;
		Ball_Y_motion <= init_Y_vel;
		Ball_X_motion <= init_X_vel;
		Size <= size_in;
		off_edge <= '1';
	-- Move ball once every vertical sync
	ELSIF (clk'event) and (clk = '1') THEN
			IF ('0' & Ball_Y_pos) >= 480 + Size + buffer_size THEN
				off_edge <= '0';
			ELSIF ('0' & Ball_X_pos) >= 640 + Size + buffer_size THEN
				off_edge <= '0';
			ELSIF Ball_X_pos <= Size THEN
				off_edge <= '0';
			ELSE
				IF (X_COUNT = 0) or (X_COUNT > Ball_X_motion) THEN 
					X_COUNT <= Ball_X_motion;
					Ball_X_pos <= Ball_X_pos + 1;
				ELSE
					X_COUNT <= X_COUNT - 1;
				END IF;
				IF (Y_COUNT = 0) or (Y_COUNT > Ball_Y_motion) THEN 
					Y_COUNT <= Ball_Y_motion;
					Ball_Y_pos <= Ball_Y_pos + 1;
				ELSE
					Y_COUNT <= Y_COUNT - 1;
				END IF;
			END IF;
	END IF;
END process Move_Ball;
END behavior;
