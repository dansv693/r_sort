-------------------------------------------------------------------------------
-- R-sort behavioral description
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- Package R_SORT
-------------------------------------------------------------------------------
package R_SORT_PKG is
  constant DATA_SIZE : integer := 4;   -- data bits
  constant ARRAY_LEN : integer := 4;   -- size of array
    
  type NUM is array(DATA_SIZE-1 downto 0) of BIT;
  type NUM_ARRAY is array (0 to ARRAY_LEN-1) of NUM;  -- input data
end;
use Work.R_SORT_PKG.all;
 
-------------------------------------------------------------------------------
-- Entity R_SORT
-------------------------------------------------------------------------------
entity R_SORT is
  
  port (
    A   : in  NUM_ARRAY;   -- unsorted input array
    CLK : in  BIT;         -- clock signal
    RST : in  BIT;         -- async reset signal
    DR  : out BIT;         -- data ready output bit
    S   : out NUM_ARRAY    -- sorted output array
		);

end R_SORT;

-------------------------------------------------------------------------------
-- High-Level architecture of R_SORT
-------------------------------------------------------------------------------
architecture HIGH_LEVEL of R_SORT is

 signal temp : NUM_ARRAY;                         -- as a signal, for simulation
  
begin  -- HIGH_LEVEL

  S <= temp;
  
  P_MAIN : process
    variable bucket_0     : NUM_ARRAY;            -- internal storage
    variable bucket_0_idx : integer := 0;         -- where to insert next data
    variable bucket_1     : NUM_ARRAY;            -- internal storage
    variable bucket_1_idx : integer := 0;         -- where to insert next data
    
    constant num_digits   : integer := DATA_SIZE; -- num significant bits
    variable temp_dest    : integer;              -- when merging used to know where to place the data
    
  begin
    wait on CLK;
    if rst = '1' then
      DR <= '0';
    else
      -- initialize numbers
      temp <= A;
      DR   <= '0';

      -------------------------------------------------------------------------
      -- main sort loop
      -------------------------------------------------------------------------
      sort_all: for significant_bit in 0 to DATA_SIZE - 1 loop

        wait on CLK;               -- to be able to see each step in simulation
        bucket_0_idx := 0;
        bucket_1_idx := 0;
        
        -----------------------------------------------------------------------
        -- sort numbers into buckets
        -----------------------------------------------------------------------
        bucketize: for i in 0 to ARRAY_LEN-1 loop
          ----------------------------------------------------------------------
          -- if the current sign. bit of the number we are looking at is 0, then
          -- move it to bucket 0, otherwise move to bucket 1
          ----------------------------------------------------------------------
          if temp(i)(significant_bit) = '0'  then  
            bucket_0(bucket_0_idx) := temp(i);
            bucket_0_idx := bucket_0_idx + 1;
          else
            bucket_1(bucket_1_idx) := temp(i);
            bucket_1_idx := bucket_1_idx + 1;     
          end if;                 
        end loop bucketize;  -- i

        -----------------------------------------------------------------------
        -- merge back into temp, first from bucket 0, and then from buket 1
        -----------------------------------------------------------------------
        temp_dest := 0;

        -- copy from bucket 0
        for i_0 in 0 to bucket_0_idx - 1 loop
          temp(temp_dest) <= bucket_0(i_0);
          temp_dest := temp_dest + 1;
        end loop;  -- i_0

        -- copy from bucket 1
        for i_1 in 0 to bucket_1_idx - 1 loop
          temp(temp_dest) <= bucket_1(i_1);
          temp_dest := temp_dest +1;  
        end loop;  -- i_0
      
      end loop sort_all;  -- significant_digit
      
      -------------------------------------------------------------------------
      --Data in temp should be sorted now, output it
      -------------------------------------------------------------------------
      DR <= '1';
    end if;      
    wait on CLK;
  end process P_MAIN;
end HIGH_LEVEL;

