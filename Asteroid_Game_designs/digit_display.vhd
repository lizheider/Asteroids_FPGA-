LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY digit_display IS
     generic(X_pos : INTEGER range 0 to 640 := 0;     --position of top left corner
				 Y_pos : INTEGER range 0 to 480 := 0);
	
	PORT(pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
		  pixel_clock					: IN std_logic;

		  digit							: IN std_logic_vector(3 DOWNTO 0);
		  white							: OUT std_logic);
END digit_display;

architecture behavior of digit_display is
 
SIGNAL Size 									: std_logic_vector(9 DOWNTO 0);  
SIGNAL Image_Y_pos, Image_X_pos			: std_logic_vector(9 DOWNTO 0);	-- keep track of which pixel of the image is being displayed
SIGNAL image_data								: std_logic_vector(7 DOWNTO 0);  -- 8-bit data from the image rom
SIGNAL rom_addr								: std_logic_vector(6 DOWNTO 0);  -- address bits for rom
SIGNAL out_on									: std_logic;

COMPONENT digits_rom
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		clock			: IN STD_LOGIC;
		q				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

BEGIN           
Size <= CONV_STD_LOGIC_VECTOR(7,10);

-- White Digit
white <= out_on and image_data((7-CONV_INTEGER(Image_X_pos(3 downto 0)))); -- 7 - pos in order to reverse order since .mif file is backwards

-- the image pixels are determined relative to the digit position and the CRT pixel position
Image_Y_pos <= pixel_row - Y_pos;
Image_X_pos <= pixel_column - X_pos;
	
RGB_Display: Process (pixel_column, pixel_row)
BEGIN
 -- Set Ball_on ='1' to display 
 IF (pixel_column >= X_pos) AND
 	 (pixel_column <= X_pos + Size) AND
 	 (pixel_row >= Y_pos) AND
 	 (pixel_row <= Y_pos + Size) THEN
		out_on <= '1';
 	ELSE
 		out_on <= '0';
END IF;
END process RGB_Display;

-- instantiate the rom and hook up the signals
digits_rom_inst : digits_rom PORT MAP (
	address	=> rom_addr,
	clock		=> pixel_clock,
	q	 		=> image_data
);
	
-- rom address
-- MSB is from switch and selects which image to display
-- other 3 bits select rom of image to display
rom_addr <= digit & Image_Y_pos(2 DOWNTO 0);
END behavior;
