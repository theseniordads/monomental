# Mono-mental

Full assembler source for the "Mono-mental" demo by The Senior Dads, which was released on the Atari 16 bit platform on the 8th April.

This release is different to other demo source code releases from us in that it's not the original source, (which is lost), but a reverse-engineer of the source code from the original binary. The original binary was disassembled and the source code was re-created from the disassembly. The original graphics and sound were also re-created from the binary. You can find out more about how this was done [here](https://github.com/theseniordads/monomental/blob/main/DOCS/README.md).

## Specifications

* An Atari ST or later with at least 1 megabytes of memory, TOS 1.04 minumum, and a hard drive.
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

## Folders

* `COMPILED` - Original compiled demo and accompanying [README](https://github.com/theseniordads/stfloormat/blob/main/COMPILED/FLOORMAT/STFLRMAT.TXT).
* `GRAPHICS` -
  * Graphics, in Degas Elite `.PI1` files.
  * `MYFONT.DAT`, a plane graphics font, used by the scroller.
  * `SYSPAL.DAT`, a binary which contains the system default colour pallette.
    for ST Lo-res.
* `INCLUDES` - Various macro and helpers code.
* `OLD` - Original version of the demo before retrofitting to be a Senior Dads demo. Note that the source code is *not* VASM compatible, and must be compiled in Devpac 3 on an Atari system.
* `SOUND` - `.THK` files are chip tune music.
  * `SENIOR.THK` - introductory fanfare.
  * `POPCORN.THK` - main music: a "version" of "Popcorn".
  * `CRASH.THK` - exit crash usic.
* `SRC_DATA` - Original versions of sound and graphics.
  * `GFX` - Source graphics. Formats used are:
    * `.PC1` - Low res Degas Elite images. Can be edited in [Degas Elite](https://dhs.nu/files.php?t=single&ID=16).
  * `SOUND` - Source sounds. Formats used are:
    * `.MUS` Chip-tunes. Can be edited using [Megatizer v2.4](https://dhs.nu/files.php?t=single&ID=50).
