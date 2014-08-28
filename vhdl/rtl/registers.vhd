--Copyright (c) 2014, Tim Wawrzynczak.
--All rights reserved.

--Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

--1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

--2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

--3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

library ieee;
use ieee.std_logic_1164.all;

use work.common.all;
use work.registers_pkg.all;

entity registers is
  
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;
    regs_in  : in  regs_in_t;
    regs_out : out regs_out_t);

end registers;

architecture rtl of registers is
  signal irqs_latch_clear : word := (others => '0');
  
begin  -- rtl

  -- Assign outputs
  regs_out.irqs_latch_clear <= irqs_latch_clear;

  -- purpose: Memory-mappable register set for the CPU
  -- type   : sequential
  -- inputs : clk, rst_n, regs_in
  -- outputs: regs_out
  regs_proc: process (clk, rst_n)
  begin  -- process regs_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
      irqs_latch_clear <= (others => '0');
    elsif rising_edge(clk) then  -- rising clock edge
      irqs_latch_clear <= regs_in.irqs_latch_clear;
    end if;
  end process regs_proc;
  
end rtl;
