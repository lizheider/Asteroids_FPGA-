LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY asteriod IS
   PORT(pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
	     pixel_clock					: IN std_logic;
		  init_X_pos 					: IN std_logic_vector(10 DOWNTO 0);
		  init_X_vel, init_Y_vel	: IN std_logic_vector(10 DOWNTO 0);
        Vert_sync						: IN std_logic;
		  en								: IN std_logic;
		  reset							: IN std_logic;
		 
		  white			 				: OUT std_logic);
END asteriod;

architecture behavior of asteriod is  -- Video Display Signals

SIGNAL Ball_on, Direction				: std_logic; 
SIGNAL Ball_Y_motion, Ball_X_motion : std_logic_vector(10 DOWNTO 0);
SIGNAL Ball_Y_pos, Ball_X_pos			: std_logic_vector(10 DOWNTO 0);
SIGNAL init_Y_pos							: std_logic_vector(10 DOWNTO 0);
SIGNAL buffer_size						: std_logic_vector(10 DOWNTO 0);
SIGNAL Size									: std_logic_vector(10 DOWNTO 0);
SIGNAL Image_Y_pos, Image_X_pos		: std_logic_vector(10 DOWNTO 0);	-- keep track of which pixel of the image is being displayed
SIGNAL image_data							: std_logic_vector(68 DOWNTO 0); -- 69-bit data from the image rom
SIGNAL rom_addr							: std_logic_vector(6 DOWNTO 0);  -- address bits for rom
SIGNAL off_edge							: std_logic;							--stores if ship should re-spawn 

--ROM for asteroid graphic
COMPONENT small_astro
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		clock			: IN STD_LOGIC;
		q				: OUT STD_LOGIC_VECTOR (68 DOWNTO 0)
	);
END COMPONENT;

BEGIN
Size <= CONV_STD_LOGIC_VECTOR(34,11); --radius of asteroid 

buffer_size <= Size(9 downto 0) & '0'; --multiply size by 2 to get buffer size
init_Y_pos <= Size; 							--start asteriod in middle of buffer

-- White Asteriod
white <= en and ball_on and image_data((CONV_INTEGER(Image_X_pos(6 downto 0))));

-- the image pixels are determined relative to the "ball" position and the CRT pixel position
Image_Y_pos <= pixel_row - Ball_Y_pos - Size + 5;
Image_X_pos <= pixel_column - Ball_X_pos - Size + 5;

RGB_Display: Process (pixel_column, pixel_row)
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

Move_Ball: process (vert_sync)
BEGIN 
	IF (reset = '0') or (off_edge ='0') THEN
		Ball_Y_pos <= Init_Y_pos;
		Ball_X_pos <= Init_X_pos;
		Ball_Y_motion <= init_Y_vel;
		Ball_X_motion <= init_X_vel;
		off_edge <= '1';
	-- Move ball once every vertical sync
	ELSIF (vert_sync'event) and (vert_sync = '1') THEN
			IF (en = '1') THEN
				--if bottom edge is past boundary 
				IF ('0' & Ball_Y_pos) >= 480 + Size + buffer_size THEN
					off_edge <= '0';
				--if right edgeis past boundary
				ELSIF ('0' & Ball_X_pos) >= 640 + Size + buffer_size THEN
					off_edge <= '0';
				--if left edge is past boundary 
				ELSIF Ball_X_pos <= Size THEN
					off_edge <= '0';
				ELSE
					-- Compute next ball Y position
					Ball_Y_pos <= Ball_Y_pos + Ball_Y_motion;
					--	Compute next ball X position
					Ball_X_pos <= Ball_X_pos + Ball_X_motion;
				END IF;
			END IF;
	END IF;
END process Move_Ball;

-- instantiate the rom and hook up the signals
small_astro_inst : small_astro PORT MAP (
	address	=> rom_addr,
	clock		=> pixel_clock,
	q	 		=> image_data
);
	
-- rom address
-- 7 bits select rom of image to display
rom_addr <= Image_Y_pos(6 DOWNTO 0);

END behavior;

