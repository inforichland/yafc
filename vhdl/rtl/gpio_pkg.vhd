-------------------------------------------------------------------------------
-- Title      : GPIO Package
-- Project    : 
-------------------------------------------------------------------------------
-- File       : gpio_pkg.vhd
-- Author     : Tim Wawrzynczak
-- Company    : 
-- Created    : 2014-07-24
-- Last update: 2014-07-24
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-07-24  1.0      TW      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package gpio_pkg is

  -----------------------------------------------------------------------------
  -- Data types
  -----------------------------------------------------------------------------

  type gpio_in_regs_t is record
    input : std_logic_vector( 15 downto 0 );
  end record;

  type gpio_out_regs_t is record
    output : std_logic_vector( 15 downto 0 );
  end record;

  type gpio_in_pins_t is record
    input : std_logic_vector( 15 downto 0 );
  end record;

  type gpio_out_pins_t is record
    output : std_logic_vector( 15 downto 0 );
  end record;
  
end gpio_pkg;
