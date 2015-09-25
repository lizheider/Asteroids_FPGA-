LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY ship IS
PORT(pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  pixel_clock					: IN std_logic;
		  u,l,r,d						: IN std_logic; 
        Vert_sync						: IN std_logic;
		  reset							: IN std_logic;
		  
		  white							: OUT std_logic);
END ship;

architecture behavior of ship is
 
SIGNAL Ball_on, Direction					: std_logic;
SIGNAL Size 									: std_logic_vector(10 DOWNTO 0);  
SIGNAL Ball_Y_motion, Ball_X_motion 	: std_logic_vector(10 DOWNTO 0);
SIGNAL Ball_Y_pos 							: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(410,11);
SIGNAL Ball_X_pos								: std_logic_vector(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(320,11);
SIGNAL Image_Y_pos, Image_X_pos			: std_logic_vector(10 DOWNTO 0);	-- keep track of which pixel of the image is being displayed
SIGNAL image_data								: std_logic_vector(30 DOWNTO 0); -- 30-bit data from the image rom
SIGNAL rom_addr								: std_logic_vector(4 DOWNTO 0);  -- address bits for rom

--rom to store ship graphic
COMPONENT ship_graphic
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		clock			: IN STD_LOGIC;
		q				: OUT STD_LOGIC_VECTOR (30 DOWNTO 0)
	);
END COMPONENT;

BEGIN           
Size <= CONV_STD_LOGIC_VECTOR(15,11); --size is measured from center position out

-- White Ship
white <= ball_on and image_data((CONV_INTEGER(Image_X_pos(4 downto 0))));

-- the image pixels are determined relative to the "ball" position and the CRT pixel position
Image_Y_pos <= pixel_row - Ball_Y_pos + Size;
Image_X_pos <= pixel_column - Ball_X_pos + Size;
	
RGB_Display: Process (pixel_column, pixel_row) --(reset, Ball_X_pos, Ball_Y_pos, pixel_column, pixel_row, Size)
BEGIN
 -- Set Ball_on ='1' to display ball
 IF ('0' & Ball_X_pos <= pixel_column + Size) AND
 	(Ball_X_pos + Size >= '0' & pixel_column) AND
 	('0' & Ball_Y_pos <= pixel_row + Size) AND
 	(Ball_Y_pos + Size >= '0' & pixel_row ) THEN
		Ball_on <= '1';
 	ELSE
 		Ball_on <= '0';
END IF;
END process RGB_Display;


Move_Ball: Process (vert_sync)
BEGIN 
	IF (reset = '0') THEN
		Ball_Y_pos <= CONV_STD_LOGIC_VECTOR(410,11);			--home y position
		Ball_X_pos <= CONV_STD_LOGIC_VECTOR(320,11);			--home x positive
	-- Move ball once every vertical sync
	ELSIF (vert_sync'event) and (vert_sync = '1') THEN
		-- Compute next ball Y position based on u and d
		IF (u = '1') and (Ball_Y_pos > Size) THEN 
			Ball_Y_pos <= Ball_Y_pos + CONV_STD_LOGIC_VECTOR(-2,11);
		END IF;
		--d takes presidence over u
		IF (d = '1') and (('0' & Ball_Y_pos) < 480 - Size) THEN
			Ball_Y_pos <= Ball_Y_pos + CONV_STD_LOGIC_VECTOR(2,11);
		END IF;
		--compute next ball X position based on r and l
		IF (r='1') and (('0' & Ball_X_pos) < 640 - Size) THEN 
			Ball_X_pos <= Ball_X_pos + CONV_STD_LOGIC_VECTOR(2,11);
		END IF;
		--l takes presidence over r
		IF (l='1') and (Ball_X_pos > Size) THEN
			Ball_X_pos <= Ball_X_pos + CONV_STD_LOGIC_VECTOR(-2,11);
		END IF;
	END IF;
END process Move_Ball;

-- instantiate the rom and hook up the signals
ship_graphic_inst : ship_graphic PORT MAP (
	address	=> rom_addr,
	clock		=> pixel_clock,
	q	 		=> image_data
);
	
-- rom address
-- MSB is from switch and selects which image to display
-- other 3 bits select rom of image to display
rom_addr <= Image_Y_pos(4 DOWNTO 0);
END behavior;

