-------------------------------------------------------------------------------
-- Title      : synchronizer
-- Project    : 
-------------------------------------------------------------------------------
-- File       : synchronizer.vhd
-- Author     : Tim Wawrzynczak
-- Company    : 
-- Created    : 2014-07-23
-- Last update: 2014-07-23
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Synchronizes an asynchronous input to a clock domain
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-07-23  1.0      TW	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity synchronizer is
  port (
    clk   : in  std_logic;
    rst_n : in  std_logic;
    ain   : in  std_logic;
    sout  : out std_logic
  );
end synchronizer;

architecture rtl of synchronizer is
  signal sync0, sync1 : std_logic := '0';
begin  -- rtl

  -----------------------------------------------------------------------------
  -- assign outputs
  -----------------------------------------------------------------------------
  sout <= sync1;
  
  -- purpose: synchronizes an asynchronous input using 2 D FFs
  -- type   : sequential
  -- inputs : clk, rst_n
  -- outputs: sout
  sync: process (clk, rst_n)
  begin  -- process sync
    if rst_n = '0' then                 -- asynchronous reset (active low)
      sync0 <= '0';
      sync1 <= '0';
    elsif rising_edge( clk ) then  -- rising clock edge
      sync0 <= ain;
      sync1 <= sync0;
    end if;
  end process sync;

end rtl;
