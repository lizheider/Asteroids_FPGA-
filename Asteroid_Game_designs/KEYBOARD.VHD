LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY keyboard IS
	PORT(	keyboard_clk, keyboard_data, clock_50MHz , 
			reset, read		: IN	STD_LOGIC;  -- the "read" input (pulse high) resets the "scan_ready" output
			scan_code		: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
			scan_ready		: OUT	STD_LOGIC); -- scan_ready is set whenever a new scan code is received
END keyboard;

ARCHITECTURE a OF keyboard IS
	SIGNAL INCNT						: std_logic_vector(3 downto 0);
	SIGNAL SHIFTIN 					: std_logic_vector(8 downto 0);
	SIGNAL READ_CHAR, clock_enable: std_logic;
	SIGNAL INFLAG, ready_set		: std_logic;
	SIGNAL keyboard_clk_filtered 	: std_logic;
	SIGNAL filter 						: std_logic_vector(7 downto 0);
BEGIN

PROCESS (read, ready_set)
BEGIN
  IF read = '1' THEN scan_ready <= '0'; -- reset scan_ready flag because client has now read the data
  ELSIF ready_set'EVENT and ready_set = '1' THEN -- if we have just finished reading a character,
		scan_ready <= '1'; -- then set scan_ready flag: ready for client to read the new character
  END IF;
END PROCESS;

-- This process filters (debounces) the raw clock signal coming 
-- from the keyboard using a shift register and two AND gates
Clock_filter: PROCESS
BEGIN
	WAIT UNTIL clock_50MHz'EVENT AND clock_50MHz = '1';
	clock_enable <= NOT clock_enable;
	IF clock_enable = '1' THEN
		filter (6 DOWNTO 0) <= filter(7 DOWNTO 1) ;
		filter(7) <= keyboard_clk;
		IF filter = "11111111" THEN keyboard_clk_filtered <= '1';
		ELSIF  filter= "00000000" THEN keyboard_clk_filtered <= '0';
		END IF;
  	END IF;
END PROCESS Clock_filter;

--This process reads in serial data coming from the terminal
PROCESS
BEGIN
WAIT UNTIL (KEYBOARD_CLK_filtered'EVENT AND KEYBOARD_CLK_filtered='1');
IF RESET='0' THEN
        INCNT <= "0000";    -- reset serial bit counter
        READ_CHAR <= '0';   -- not currently reading a character
        ready_set <= '0';   -- no data ready to output yet
ELSE
  IF KEYBOARD_DATA='0' AND READ_CHAR='0' THEN -- start bit detected... (clock edge)
        READ_CHAR <= '1';   -- we are now beginning to read a character from the keyboard
		ready_set   <= '0';   -- the character is not yet finished being read - reset this internal signal to zero
  ELSE -- Shift in next 8 data bits to assemble a scan code			
    IF READ_CHAR = '1' THEN -- if we are currently reading a character
        IF INCNT < "1001" THEN
         	INCNT <= INCNT + 1;
         	SHIFTIN(7 DOWNTO 0) <= SHIFTIN(8 DOWNTO 1); -- rightshift the other bits,
         	SHIFTIN(8) <= KEYBOARD_DATA; -- input the new bit from keyboard on the left			
        ELSE -- End of scan code character (on the 9th clock edge, not counting the clock edge of the start 
		       -- bit), so set flags and exit loop (don't save parity bit)
	 	   	scan_code 	<= SHIFTIN(7 DOWNTO 0); -- put the 8 recently-received bits to the output
	   		READ_CHAR	<= '0';  -- finished reading the character, no longer in read_char mode
	    	ready_set 		<= '1';     -- set internal signal high to trigger scan_ready output to go high in above process
	    	INCNT 			<= "0000";
        END IF;
     END IF;
  END IF;
END IF;
END PROCESS;
END a;