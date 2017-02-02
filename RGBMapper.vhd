LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


Entity RGBMapper is
	Port ( 
		Red, Green, Blue : in STD_LOGIC_VECTOR(7 downto 0) ;
		RedOut, GreenOut, BlueOut : out STD_LOGIC_VECTOR(9 downto 0) 
		);	
end;

Architecture a of RGBMapper is
begin
	RedOut(9) <= Red(7) ;
	RedOut(8) <= Red(6) ;
	RedOut(7) <= Red(5) ;
	RedOut(6) <= Red(4) ;
	RedOut(5) <= Red(3) ;
	RedOut(4) <= Red(2) ;
	RedOut(3) <= Red(1) ;
	RedOut(2) <= Red(0) ;
	RedOut(1) <= '0' ;
	RedOut(0) <= '0' ;
	
	GreenOut(9) <= Green(7) ;
	GreenOut(8) <= Green(6) ;
	GreenOut(7) <= Green(5) ;
	GreenOut(6) <= Green(4) ;
	GreenOut(5) <= Green(3) ;
	GreenOut(4) <= Green(2) ;
	GreenOut(3) <= Green(1) ;
	GreenOut(2) <= Green(0) ;
	GreenOut(1) <= '0' ;
	GreenOut(0) <= '0' ;
	
	BlueOut(9) <= Blue(7) ;
	BlueOut(8) <= Blue(6) ;	
	BlueOut(7) <= Blue(5) ;
	BlueOut(6) <= Blue(4) ;
	BlueOut(5) <= Blue(3) ;
	BlueOut(4) <= Blue(2) ;
	BlueOut(3) <= Blue(1) ;
	BlueOut(2) <= Blue(0) ;
	BlueOut(1) <= '0' ;
	BlueOut(0) <= '0' ;
end ;
