LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY num_to_digits IS

	PORT(number							: IN std_logic_vector(13 DOWNTO 0);
		  
		  digit1							: OUT std_logic_vector(3 DOWNTO 0);
		  digit2							: OUT std_logic_vector(3 DOWNTO 0);
		  digit3							: OUT std_logic_vector(3 DOWNTO 0);
		  digit4							: OUT std_logic_vector(3 DOWNTO 0));
END num_to_digits;

architecture behavior of num_to_digits is
SIGNAL int_number						: INTEGER range 0 to 9999;
SIGNAL int_1   						: INTEGER range 0 to 9;
SIGNAL int_2   						: INTEGER range 0 to 9;
SIGNAL int_3   						: INTEGER range 0 to 9;
SIGNAL int_4   						: INTEGER range 0 to 9;

BEGIN           
int_number <= CONV_INTEGER(number);
int_1 <= (int_number mod 10);						--find one digit
int_2 <= (int_number / 10) mod 10;				--find tens digit
int_3 <= (int_number / 100) mod 10;				-- find hundreds digit
int_4 <= (int_number / 1000) mod 10 ;			--find thousands digit

digit1 <= CONV_STD_LOGIC_VECTOR(int_1, 4);
digit2 <= CONV_STD_LOGIC_VECTOR(int_2, 4);
digit3 <= CONV_STD_LOGIC_VECTOR(int_3, 4);
digit4 <= CONV_STD_LOGIC_VECTOR(int_4, 4);
	
END behavior;