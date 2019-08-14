library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

use IEEE.numeric_std.all;

use IEEE.std_logic_signed.all;

use IEEE.std_logic_unsigned.all;

entity project_reti_logiche is

    Port ( i_clk : in STD_LOGIC;

           i_start : in STD_LOGIC;

           i_rst : in STD_LOGIC;

           i_data : in STD_LOGIC_VECTOR(7 downto 0);

           o_address : out STD_LOGIC_VECTOR(15 downto 0);

           o_done : out STD_LOGIC;

           o_en : out STD_LOGIC;

           o_we : out STD_LOGIC;

           o_data : out STD_LOGIC_VECTOR(7 downto 0)

         );

end project_reti_logiche;



architecture Behavioral of project_reti_logiche is

type state_type is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11);

signal CURRENT_STATE, NEXT_STATE: state_type;

signal mask_in,x_punto,y_punto,x_centroide,y_centroide,result : SIGNED(8 downto 0);

signal tmp_distance,distance,x_distance,y_distance,ovrflw: SIGNED(8 downto 0);

signal i_address,tmp_address : STD_LOGIC_VECTOR(15 downto 0);

begin



Start: process(i_clk,i_rst)

    begin

    if(i_rst= '1') then

        CURRENT_STATE <= s0;

    elsif(i_clk'EVENT and i_clk='1') then

        CURRENT_STATE <= NEXT_STATE;

    end if;

    end process;



State_machine: process(CURRENT_STATE,i_clk,i_start,i_data,i_address,tmp_address)

    VARIABLE position : INTEGER;

    begin

    if(i_start = '0') then

        o_done <= '0';

    elsif(i_clk'EVENT and i_clk='1' and i_start= '1') then

    case CURRENT_STATE is

        when s0 =>

            o_done <= '0';

            o_en <= '1';

            o_we <= '0';

            distance <= (others => '1');

            o_address <= (others => '0');

            result <= (others => '0');

            tmp_address <= "0000000000000001";

            NEXT_STATE <= s1;

        when s1 =>

            mask_in(7 downto 0) <= SIGNED(i_data);

            mask_in(8) <= '0';

            o_address <= "0000000000010001";

            NEXT_STATE <= s2;

        when s2 =>

            x_punto(7 downto 0)  <= SIGNED(i_data); 

            x_punto(8) <= '0';

            o_address <= "0000000000010010";

            NEXT_STATE <= s3;

        when s3 =>

            y_punto(7 downto 0)  <= SIGNED(i_data);

            y_punto(8) <= '0'; 

            o_address <= "0000000000000001";

            i_address <= "0000000000000001";

            position := to_integer(shift_right(SIGNED(SIGNED(i_address) - 1), 1));

            NEXT_STATE <= s4;

        when s4 =>

           if(mask_in(position) = '0') then

                if(i_address = 15 and position = 7) then

                    NEXT_STATE <= s11;

                else

                    tmp_address <= i_address;

                    o_address <= STD_LOGIC_VECTOR(SIGNED(SIGNED(tmp_address) + 2));

                    i_address <= STD_LOGIC_VECTOR(SIGNED(SIGNED(tmp_address) + 2));

                    position := to_integer(shift_right(SIGNED(i_address), 1));

                    NEXT_STATE <= s4;

                end if;

            else

                position := to_integer(shift_right(SIGNED(i_address), 1));

                x_centroide(7 downto 0)  <= SIGNED(i_data); 

                x_centroide(8) <= '0';

                tmp_address <= i_address;

                o_address <= STD_LOGIC_VECTOR(SIGNED(SIGNED(tmp_address) + 1));

                i_address <= STD_LOGIC_VECTOR(SIGNED(SIGNED(tmp_address) + 1));

                NEXT_STATE <= s5;

             end if;

        when s5 =>

            y_centroide(7 downto 0)  <= SIGNED(i_data); 

            y_centroide(8) <= '0';

            x_distance <= x_punto - x_centroide;

            y_distance <= y_punto - y_centroide;

            ovrflw <= x_distance;

            NEXT_STATE <= s6;

        when s6 =>

           if(x_distance(8) = '1') then

                x_distance <= SIGNED(0 - ovrflw);

                ovrflw <= y_distance;

                NEXT_STATE <= s7;

            else

            ovrflw <= y_distance;

            NEXT_STATE <= s7;

            end if;

        when s7 =>

            if(y_distance(8) = '1') then

                y_distance <= SIGNED(0 - ovrflw);

                NEXT_STATE <= s8;

            else

            NEXT_STATE <= s8;

            end if;

        when s8 =>

           tmp_distance <= x_distance + y_distance;

            NEXT_STATE <= s9;

        when s9 =>

            if(UNSIGNED(distance) = UNSIGNED(tmp_distance)) then

                result(position-1) <= '1';

                NEXT_STATE <= s10;

            elsif(UNSIGNED(distance) < UNSIGNED(tmp_distance)) then

                NEXT_STATE <= s10;

            elsif(UNSIGNED(distance) > UNSIGNED(tmp_distance)) then

                result <= (others => '0');

                result(position-1) <= '1';

                distance <= tmp_distance;

                NEXT_STATE <= s10;

            else

                NEXT_STATE <= s10;

            end if;

        when s10 =>

             if(i_address = 16) then

                NEXT_STATE <= s11;

            else

                tmp_distance(8) <= '0';

                tmp_address <= i_address;

                o_address <= STD_LOGIC_VECTOR(SIGNED(SIGNED(tmp_address) + 1));

                i_address <= STD_LOGIC_VECTOR(SIGNED(SIGNED(tmp_address) + 1));

                NEXT_STATE <= s4;

            end if;

        when s11 =>

	    o_address <= "0000000000010011";   

            o_data <= STD_LOGIC_VECTOR(result(7 downto 0));

            o_we <= '1';

            o_done <= '1';

            NEXT_STATE <= s0;

    end case;

    end if;

    end process;

    



end Behavioral;
