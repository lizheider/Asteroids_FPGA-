-- Bouncing Ball Video 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY collision_detection IS
   PORT(	ship_pos_X										: IN std_logic_vector(9 DOWNTO 0);
			ship_pos_Y										: IN std_logic_vector(9 DOWNTO 0);
			ship_height										: IN std_logic_vector(9 DOWNTO 0);
			ship_width										: IN std_logic_vector(9 DOWNTO 0);
			
			a1_pos_X											: IN std_logic_vector(9 DOWNTO 0);
			a1_pos_Y											: IN std_logic_vector(9 DOWNTO 0);
			a1_height										: IN std_logic_vector(9 DOWNTO 0);
			a1_width											: IN std_logic_vector(9 DOWNTO 0);
			
			collide											: OUT std_logic);
			
	);
END collision_detection;

architecture behavior of collision_detection is  -- Video Display Signals

BEGIN  

Crash: Process (ship_pos_X, ship_pos_Y, ship_height, ship_width, a1_pos_X, a1_pos_Y, a1_height, a1_width)
BEGIN
 IF ('0' & Ball_X_pos <= pixel_column + Size + buffer_size) AND
 	 (Ball_X_pos + Size >= '0' & pixel_column + buffer_size) AND
 	 ('0' & Ball_Y_pos <= pixel_row + Size + buffer_size) AND
 	 (Ball_Y_pos + Size >= '0' & pixel_row + buffer_size) THEN
 		Ball_on <= '1';
 	ELSE
 		Ball_on <= '0';
END IF;
END process RGB_Display;

Move_Ball: process (vert_sync)
BEGIN 
	IF (reset = '0') THEN
		Ball_Y_pos <= Init_Y_pos;
		Ball_X_pos <= Init_X_pos;
		Ball_Y_motion <= init_Y_vel;
		Ball_X_motion <= init_X_vel;
		off_edge <= '1';
	-- Move ball once every vertical sync
	ELSIF (vert_sync'event) and (vert_sync = '1') THEN
			IF ('0' & Ball_Y_pos) >= 480 + Size + buffer_size THEN
				off_edge <= '0';
			END IF;
			--restart after going past edge
			IF ('0' & Ball_X_pos) >= 640 + Size + buffer_size THEN
				off_edge <= '0';
			ELSIF Ball_X_pos <= Size THEN
				off_edge <= '0';
			END IF;
			
			-- Compute next ball Y position
			Ball_Y_pos <= Ball_Y_pos + Ball_Y_motion;
			--	Compute next ball X position
			Ball_X_pos <= Ball_X_pos + Ball_X_motion;
	END IF;
END process Move_Ball;
END behavior;

