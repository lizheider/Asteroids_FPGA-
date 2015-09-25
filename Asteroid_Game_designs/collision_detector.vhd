-- Bouncing Ball Video 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY collision_detector IS
   PORT(
			Sx 				: IN std_logic_vector(10 DOWNTO 0);
			Sy 				: IN std_logic_vector(10 DOWNTO 0);
			Sw 				: IN std_logic_vector(10 DOWNTO 0);
			Sh 				: IN std_logic_vector(10 DOWNTO 0);
			
			A1x 				: IN std_logic_vector(10 DOWNTO 0);
			A1y 				: IN std_logic_vector(10 DOWNTO 0);
			A1w 				: IN std_logic_vector(10 DOWNTO 0);
			A1h 				: IN std_logic_vector(10 DOWNTO 0);
			
			hit				: OUT std_logic);
END collision_detector;

architecture behavior of collision_detector is  -- Video Display Signals

BEGIN  

Detect_Collision: Process (Sx, Sy, Sw, Sh, A1x, A1y, A1w, A1h)
BEGIN
	IF Sx >= A1x THEN 
		IF Sy >= A1y THEN 
			IF (Sx - A1x <= Sw + A1w) AND (Sy - A1y <= Sh + A1h) THEN
				hit <= '0';
			ELSE
				hit <= '1';
			END IF;
		ELSE
			IF (Sx - A1x <= Sw + A1w) AND (A1y - Sy <= Sh + A1h) THEN
				hit <= '0';
			ELSE
				hit <= '1';
			END IF;
		END IF;
	ELSE
		IF Sy >= A1y THEN 
			IF (A1x - Sx <= Sw + A1w) AND (Sy - A1y <= Sh + A1h) THEN
				hit <= '0';
			ELSE
				hit <= '1';
			END IF;
		ELSE
			IF (A1x - Sx <= Sw + A1w) AND (A1y - Sy <= Sh + A1h) THEN
				hit <= '0';
			ELSE
				hit <= '1';
			END IF;
		END IF;
	END IF;

END process Detect_Collision;


END behavior;