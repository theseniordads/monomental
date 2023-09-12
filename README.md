# Mono-mental

Full assembler source for the "Mono-mental" demo by The Senior Dads, which was released on the Atari 16 bit platform on the 11th April 1998 at the first ALT Party in Turku, Finland.

This release is different to other demo source code releases from us in that it's not the original source, (which is lost), but a reverse-engineer of the source code from the original binary. The original binary was disassembled and the source code was re-created from the disassembly. The original graphics and sound were also re-created from the binary. You can find out more about how this was done [here](https://github.com/theseniordads/monomental/blob/main/DOCS/README.md).

There are two versions of the source code in this release. The first is a straight reverse-engineer of the original binary, and resides in the `[remaster](https://github.com/theseniordads/monomental/tree/remaster)` branch. The second is a tweaked version of the reverse-engineered source code, and resides in the `[remix](https://github.com/theseniordads/monomental/tree/remix)` branch.

## Specifications

* An Atari ST or later with at least 1 megabytes of memory, TOS 1.04 minumum, a hard drive, and **hi-res mono monitor**.
* ... Alternatively, a decent emulator like Hatari, configured as above.
* Devpac 3 to assemble the code.
* Atomix packer or better to pack the executable.

## How to assemble on an Atari

* Load "MAIN.S" into Devpac 3.
* Make sure settings are set to assemble to Motorola 68000.
* Assemble to executable file "MAIN.PRG".
* Rename exectuable to "MONOMNTL.TOS".
* Pack "MONOMNTL.TOS" with packer. (**NOTE**: Atomix packer v3.6 is not compatible with the Atari Falcon.)
* Run "MONOMNTL.TOS".

## How to assemble on modern systems

This requires [VASM](http://sun.hasenbraten.de/vasm/https:/) and [Vlink](http://www.compilers.de/vlink.html), which you can get for most modern systems.

To compile the source:

`vasmm68k_mot main.s build/main.o -m68000 -Felf -noesc -quiet -no-opt`

To turn the compiled binary to an Atari executable:

`vlink build/main.o build/MONOMNTL.TOS -bataritos`

## Files

* `MAIN.S` - Main source code file. Assemble this to create the demo.
* `COMPILED` - Compiled versions of the demo.
  * `ORIGINAL` - Original compiled demo and accompanying [README](https://github.com/theseniordads/stfloormat/blob/main/COMPILED/MONOMNTL.TXT).
  * `REMASTER` - Compiled version of the demo from the reverse-engineered source code.
  * `REMIX` - Compiled version of the demo from a tweaked version of reverse-engineered source code.
* `GRAPHICS` 
  * `BITMAPS`- Despite the name, these are uncompressed Degas Elite PI3 images. They're just *used* like bitmaps.
  * `PACKED`- Degas Elite PI3 images packed with Atomix v3.5 packer. Used by the code.
  * `UNPACKED`- the unpacked versions of the above. *Not* used by the code.
  * `SENIOR_L.OGO` - The Senior Dads logo in ASCII text. Designed for use in ST Med or Hi resoloution.
* `DEMOPARTS` - Inidividual parts of the demo, used by `MAIN.S`.
* `DISASSEMB/MONOMNTL.S` - Disassembly of the original binary using TT-Digger. This is what we started out with!
* `DOCS/README.md` - [How we reverse-engineered the demo](https://github.com/theseniordads/monomental/blob/main/DOCS/README.md).
* `INCLUDES` - Various macro and helpers code.
* `OLD` - Earlier incomplete version of the demo. Note that the source code has **not** been checked for VASM compatiblity, and is designed to be compiled in Devpac 3 on an Atari system.

* `SOUND` - `.THK` Chip tune music used by the demo.
  * `CRASH.THK` - Exit crash music.
  * `FANFARE.THK` - "Senior Dads present..." introductory fanfare.
  * `MONOMNTL.THK` - Main demo music.
  * `STATIC.THK` - TV static noise.
  * `TESTCARD.THK` - "Test Card" screen music.
