LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all ;

-- ColourPallette

entity ColourPalletteLookup is
	Port (
		Address		: in std_logic_Vector(7 downto 0);		-- 1024 locations 
		
		RedOut  		: out std_logic_vector(7 downto 0);		-- 8 bits of Red
		GreenOut  	: out std_logic_vector(7 downto 0);		-- 8 bits of Green
		BlueOut  	: out std_logic_vector(7 downto 0)		-- 8 bits of Blue
	);
end ;

-- RGB values
-- see http://www.rapidtables.com/web/color/RGB_Color.htm

architecture bhvr of ColourPalletteLookup is
	type ColourPalletteRom is array ( 0 to 255) of std_logic_vector(23 downto 0);	-- 256 colours with 8 bits of RGB each
	constant MyRom : ColourPalletteRom := 
						(
								X"000000", -- Black
								X"FFFFFF", -- White
								X"FF0000", -- Red
								X"00FF00", -- Green/Lime
								X"0000FF", -- Blue
								X"FFFF00", -- Yellow
								X"00FFFF", -- Cyan
								X"FF00FF", -- Magenta
								X"C0C0C0", -- Silver
								X"808080", -- Gray
								X"800000", -- Maroon
								X"808000", -- Olive
								X"008000", -- DarkGreen
								X"800080", -- Purple
								X"008080", -- Teal
								X"000080", -- Navy				
								X"8B0000", -- Dark Red
								X"A52A2A", -- Brown
								X"B22222", -- FireBrick
								X"DC143C", -- Crimson
								X"FF6347", -- Tomato
								X"FF7F50", -- Coral
								X"Cd5C5C", -- Indian Red
								X"F08080", -- Light Coral
								X"E9967A", -- Dark Salmon
								X"FA8072", -- Salmon
								X"FFA07A", -- Light Salmon
								X"FF4500", -- Orange Red
								X"FF8C00", -- Dark Orange
								X"FFA500", -- Orange
								X"FFD700", -- Gold
								X"B8860B", -- Dark Golden Rod
								X"DAA520", -- Golden Rod
								X"EEE8AA", -- Pale Golden Rod
								X"BDB76B", -- Dark Kharki
								X"F0E68C", -- Khaki
								X"808000", -- Olive
								X"FFFF00", -- Yellow
								X"9ACD32", -- Yellow Green
								X"556B2F", -- Dark Olive Green
								X"6B8E23", -- Olive Drab
								X"7CFC00", -- Lawn Green
								X"7FFF00", -- Chart Reuse
								X"ADFF2F", -- Green Yellow
								X"006400", -- Dark Green
								X"008000", -- Green
								X"228B22", -- Forest Green
								X"00FF00", -- Green/Lime
								X"32CD32", -- Lime Green
								X"90EE90", -- Light Green
								X"98FB98", -- Pale Green
								X"8FBC8F", -- Dark See Green
								X"00FA9A", -- Medium Spring Green
								X"00FF7F", -- Spring Green
								X"2E8B57", -- Sea Green
								X"66CDAA", -- Medium Aqua Marine
								X"3CB371", -- Medium Sea Green
								X"20B2AA", -- Light Sea Green
								X"2F4F4F", -- Dark Slate Gray
								X"008080", -- Teal
								X"008B8B", -- Dark Cyan
								X"00FFFF", -- Aqua/Cyan
								X"E0FFFF", -- Light Cyan
								X"00CED1", -- Dark Turquise
								X"40E0D0", -- Turquoise
								X"48D1CC", -- Medium Turquoise
								X"AFEEEE", -- Pale Turquoise
								X"7FFFD4", -- Aqua Marine
								X"B0E0E6", -- Powder Blue
								X"5F9EA0", -- Cadet Blue
								X"4682B4", -- Steel Blue
								X"6495ED", -- Corn Flower Blue
								X"00BFFF", -- Deep Sky Blue
								X"1E90FF", -- Dodger Blue
								X"ADD8E6", -- Light Blue
								X"87CEEB", -- Sky Blue
								X"87CEFA", -- Light Sky Blue
								X"191970", -- Midnight Blue
								X"000080", -- Navy
								X"00008B", -- Bark Blue
								X"0000CD", -- Medium Blue
								X"0000FF", -- Blue
								X"4169E1", -- Royal Blue
								X"8A2BE2", -- Blue Violet
								X"4B0082", -- Indigo
								X"483D8B", -- Dark Slate Blue
								X"6A5ACD", -- Slate Blue
								X"7B68EE", -- Medium Slate Blue
								X"9370DB", -- Medium Purple
								X"8B008B", -- Dark Magenta
								X"9400D3", -- Dark Violet
								X"9932CC", -- Dark Orchid"
								X"BA55D3", -- Medium Orchid
								X"800080", -- Purple
								X"D8BFD8", -- Thistle
								X"DDA0DD", -- Plum
								X"EE82EE", -- Violet
								X"FF00FF", -- Magenta/Fuchia
								X"DA70D6", -- Orchid
								X"C71585", -- Medium Violet Red
								X"DB7093", -- Pale Violet Red
								X"FF1493", -- Deep Pink
								X"FF69B4", -- Hot Pink
								X"ffB6C1", -- Light Pink
								X"FFC0CB", -- Pink
								X"FAEBD7", -- Antique White
								X"F5F5DC", -- Beige
								X"FFE4C4", -- Bisque
								X"FFEBCD", -- Blanched Almond
								X"F5DEB3", -- Wheat
								X"FFF8DC", -- Corn Silk
								X"FFFACD", -- Lemon Chiffon
								X"FAFAD2", -- Light Golden Rod Yellow
								X"FFFFE0", -- Light Yellow
								X"8B4513", -- Saddle Brown
								X"A0522D", -- Sienna
								X"D2691E", -- Chocolate
								X"CD853F", -- Peru
								X"F4A460", -- Sandy Brown
								X"DEB887", -- Burley Wood
								X"D2B48C", -- Tan
								X"BC8F8F", -- Rosy Tan
								X"FFE4B5", -- Moccasin
								X"FFDEAD", -- Navajo White
								X"FFDAB9", -- Peach Puff
								X"FFE4E1", -- Misty Rose
								X"FFF0F5", -- Lavendar Blush
								X"FAF0E6", -- Linen
								X"FDF5E6", -- Old Lace
								X"FFEFD5", -- Papaya Whip
								X"FFF5EE", -- Sea Shell
								X"F5FFFA", -- Mint Cream
								X"708090", -- Slate Gray
								X"778899", -- Light Slate Gray
								X"B0C4DE", -- Light Steel Blue
								X"E6E6FA", -- Lavender
								X"FFFAF0", -- Floral White
								X"F0F8FF", -- Alice Blue
								X"F8F8FF", -- Ghost White
								X"F0FFF0", -- Honey Dew
								X"FFFFF0", -- Ivory
								X"F0FFFF", -- Azure
								X"FFFAFA", -- Snow
								X"000000", -- Black
								X"696969", -- Dim Gray
								X"808080", -- Gray
								X"A9A9A9", -- Dark Gray
								X"D3D3D3", -- Light Gray
								X"DCDCDC", -- GainsBoro
								X"F5F5F5", -- White Smoke
								X"FFFFFF", -- White
								
-- Repeating colour - change these if you like
								X"000000", -- Black
								X"FFFFFF", -- White
								X"FF0000", -- Red
								X"00FF00", -- Green/Lime
								X"0000FF", -- Blue
								X"FFFF00", -- Yellow
								X"00FFFF", -- Cyan
								X"FF00FF", -- Magenta
								X"C0C0C0", -- Silver
								X"808080", -- Gray
								X"800000", -- Maroon
								X"808000", -- Olive
								X"008000", -- DarkGreen
								X"800080", -- Purple
								X"008080", -- Teal
								X"000080", -- Navy				
								X"8B0000", -- Dark Red
								X"A52A2A", -- Brown
								X"B22222", -- FireBrick
								X"DC143C", -- Crimson
								X"FF6347", -- Tomato
								X"FF7F50", -- Coral
								X"Cd5C5C", -- Indian Red
								X"F08080", -- Light Coral
								X"E9967A", -- Dark Salmon
								X"FA8072", -- Salmon
								X"FFA07A", -- Light Salmon
								X"FF4500", -- Orange Red
								X"FF8C00", -- Dark Orange
								X"FFA500", -- Orange
								X"FFD700", -- Gold
								X"B8860B", -- Dark Golden Rod
								X"DAA520", -- Golden Rod
								X"EEE8AA", -- Pale Golden Rod
								X"BDB76B", -- Dark Kharki
								X"F0E68C", -- Khaki
								X"808000", -- Olive
								X"FFFF00", -- Yellow
								X"9ACD32", -- Yellow Green
								X"556B2F", -- Dark Olive Green
								X"6B8E23", -- Olive Drab
								X"7CFC00", -- Lawn Green
								X"7FFF00", -- Chart Reuse
								X"ADFF2F", -- Green Yellow
								X"006400", -- Dark Green
								X"008000", -- Green
								X"228B22", -- Forest Green
								X"00FF00", -- Green/Lime
								X"32CD32", -- Lime Green
								X"90EE90", -- Light Green
								X"98FB98", -- Pale Green
								X"8FBC8F", -- Dark See Green
								X"00FA9A", -- Medium Spring Green
								X"00FF7F", -- Spring Green
								X"2E8B57", -- Sea Green
								X"66CDAA", -- Medium Aqua Marine
								X"3CB371", -- Medium Sea Green
								X"20B2AA", -- Light Sea Green
								X"2F4F4F", -- Dark Slate Gray
								X"008080", -- Teal
								X"008B8B", -- Dark Cyan
								X"00FFFF", -- Aqua/Cyan
								X"E0FFFF", -- Light Cyan
								X"00CED1", -- Dark Turquise
								X"40E0D0", -- Turquoise
								X"48D1CC", -- Medium Turquoise
								X"AFEEEE", -- Pale Turquoise
								X"7FFFD4", -- Aqua Marine
								X"B0E0E6", -- Powder Blue
								X"5F9EA0", -- Cadet Blue
								X"4682B4", -- Steel Blue
								X"6495ED", -- Corn Flower Blue
								X"00BFFF", -- Deep Sky Blue
								X"1E90FF", -- Dodger Blue
								X"ADD8E6", -- Light Blue
								X"87CEEB", -- Sky Blue
								X"87CEFA", -- Light Sky Blue
								X"191970", -- Midnight Blue
								X"000080", -- Navy
								X"00008B", -- Bark Blue
								X"0000CD", -- Medium Blue
								X"0000FF", -- Blue
								X"4169E1", -- Royal Blue
								X"8A2BE2", -- Blue Violet
								X"4B0082", -- Indigo
								X"483D8B", -- Dark Slate Blue
								X"6A5ACD", -- Slate Blue
								X"7B68EE", -- Medium Slate Blue
								X"9370DB", -- Medium Purple
								X"8B008B", -- Dark Magenta
								X"9400D3", -- Dark Violet
								X"9932CC", -- Dark Orchid"
								X"BA55D3", -- Medium Orchid
								X"800080", -- Purple
								X"D8BFD8", -- Thistle
								X"DDA0DD", -- Plum
								X"EE82EE", -- Violet
								X"FF00FF", -- Magenta/Fuchia
								X"DA70D6", -- Orchid
								X"C71585", -- Medium Violet Red
								X"DB7093", -- Pale Violet Red
								X"FF1493", -- Deep Pink
								X"FF69B4", -- Hot Pink
								X"ffB6C1", -- Light Pink
								X"FFC0CB"  -- Pink
						);
Begin
	process(Address)
		variable	index : integer range 0 to 255 ;	
	begin
		index := to_integer(unsigned(Address)) ;
		RedOut <= MyRom(index)(23 downto 16);
		GreenOut <= MyRom(index)(15 downto 8);
		BlueOut <= MyRom(index)(7 downto 0);
	end process ;
END ;

