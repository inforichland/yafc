README
======

YAFC - Yet Another Forth Core
-----------------------------
Yes, it's been done to death... *another* stack machine optimized for Forth, and oh look, it's written in VHDL, how boring.  Well, I wanted to get my hands dirty anyways :)

What It Is
----------
YAFC (rhymes with KAFKA) is a soft-core, FPGA-targeted 16-bit dual-stack processor.  It is designed to run Forth code natively.  
It currently supports all of what I call the "primitive" Forth operations.

Design Goals
------------
1. Soft-core processor (targeted at small Xilinx and Altera's smaller offerings).  
2. Written entirely in portable VHDL'93 (prefer inference to instantiation of device primitives, to encourage reuse).  The only caveat here is the PLL.  This obviously calls for a vendor-specific IP core, depending on what brand of FPGA you use.
3. Support single-cycle execution of as many Forth "primitives" as possible (I believe more than the full subset necessary to implement the interpreter in software is implemented).
4. Target 100MHz+ clock speed on a Xilinx Spartan-6 (Papilio Pro w/ LogicStart MegaWing - XC6SLX9).
5. Take up less than 20% of slices on target device.  (Currently it occupies 13% of the device's slices, and 25% of BRAM).  It wouldn't be difficult to modify it to use less RAM; you would basically throw away some of the top instruction bits.  I consider the goal met.
6. Write a bootloader for it.

And... ?
--------
Well, I think I pretty much met my goals for this one.  It's definitely got areas it could be improved.  I was sort of lazy with adding functionality, only adding it when it was needed, which is why opcode selection is a little sloppy.

Specs
-----
+ 100 MHz 16-bit dual stack processor.
+ Supports a generous subset of Forth primitives.
+ 32-word deep data stack, 32-word deep return stack
+ Supports single-cycle execution of nearly all opcodes (exceptions are jumps, branches, calling a word, or returning from a word).  The overhead of calling a word (subroutine) is only 2 extra cycles, and with a 32 word deep return stack, highly factored code is encouraged.
+ Serial (RS-232) bootloader, is the default program loaded into the onboard SRAM.  There is an accompanying Python script which can send an Xilinx-style memory initialization file over your computer's UART to the running YAFC core, and then it will run that program until it is reset or turned off (several examples included).  
+ An assembler, written in Python.  Note that programs are written as Python programs, and should be bootloaded into the core, after assembly.  Also note that this file is a giant hack; in my defense, it was just something to get me going ASAP when I was ready to run programs in the core.
+ 8K of Program / Memory space, and 8K of I/O space.  
+ UART and GPIO are the only (admittedly very simple) peripherals implemented as of yet.

License
-------
Copyright (c) 2014, Tim Wawrzynczak.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. Neither the name of the nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


Influences
----------
+ [J1](http://excamera.com/sphinx/fpga-j1.html)
+ [F16](http://www.richardhaskell.com/files/forthcoremm.pdf)
+ [C18](http://www.colorforth.com/)
