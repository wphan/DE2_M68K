LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity CPU_DMA_Mux is
	Port (
	
		CPU_DMA_Select 		: in std_logic ;		-- 0 select DMA, 1 select CPU inputs
				
		DMA_Address 		: in Std_logic_vector(31 downto 0) ;
		DMA_DataBusOut 		: in std_logic_vector(15 downto 0) ;
		DMA_AS_L 			: in std_logic ;
		DMA_RW 				: in std_logic ;
		DMA_UDS_L 			: in std_logic ;
		DMA_LDS_L 			: in std_logic ;
		
		CPU_Address 		: in Std_logic_vector(31 downto 0) ;
		CPU_DataBusOut 		: in std_logic_vector(15 downto 0) ;
		CPU_AS_L 			: in std_logic ;
		CPU_UDS_L 			: in std_logic ;
		CPU_LDS_L 			: in std_logic ;
		CPU_RW 				: in std_logic ;		

		
		AddressOut 		: out Std_logic_vector(31 downto 0) ;
		DataOut 		: out std_logic_vector(15 downto 0) ;
		AS_L 			: out std_logic ;

		UDS_L 			: out std_logic ;
		LDS_L 			: out std_logic ; 
		RW 				: out std_logic 	
		);
end ;


architecture bhvr of CPU_DMA_Mux is
Begin
	process(DMA_Address, DMA_DataBusOut, DMA_AS_L, DMA_RW, DMA_UDS_L, DMA_LDS_L, CPU_Address, CPU_DataBusOut, CPU_AS_L, CPU_RW, CPU_UDS_L, CPU_LDS_L, CPU_DMA_Select)
	begin
		if(CPU_DMA_Select = '1') then 		-- select CPU signals and map to outputs
			AddressOut 	<= CPU_Address ;
			DataOut 	<= CPU_DataBusOut;
			AS_L 		<= CPU_AS_L ;
			RW 			<= CPU_RW ;
			UDS_L 		<= CPU_UDS_L ;
			LDS_L 		<= CPU_LDS_L ;
		else
			AddressOut 	<= DMA_Address ;
			DataOut 	<= DMA_DataBusOut;
			AS_L 		<= DMA_AS_L ;
			RW 			<= DMA_RW ;
			UDS_L 		<= DMA_UDS_L ;
			LDS_L 		<= DMA_LDS_L ;
		end if ;
	end process ;
END ;