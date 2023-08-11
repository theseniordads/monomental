# "Mono-Mental" recompilation notes

By **THE SENIOR DADS**

11 Aug 2023

We've recently been adding the source code of our old Atari demos to our [GitHub page](https://github.com/theseniordads), as part of our testing out using modern dev systems to create new Atari code! These days you can use a modern dev enviroment on Windows, Mac or Linux to crank out code, which you can then assemble, using [VASM](http://sun.hasenbraten.de/vasm/) and [Vlink](http://www.compilers.de/vlink.html), to an Atari excutable, which you can then run on an Atari emulator such as [Hatari](https://hatari.tuxfamily.org/)!

In the majority of cases, we had the source code to hand, and all we really had to was check it could assemble on a modern system, and the resulting executable could run on Hatari. VASM and Vlink are more or less compatible with the sort of assembler code you would write in Devpac in  the old Atari days, but there are one or two syntax things that you may have to change in order to get the code to assemble. (We'll mention those later.)

**Mono-mental** was a different case altogether as we didn't have the source code for the full demo, only an early version with the just an early version of "Yogie Baird" screen completed! (You can find this in the `OLD` folder.) It's interesting in it's own right, as there's a lot of "what if?"s in the demo at this stage, but it's certainly nowhere near the complete demo as released!

If we were doing this on the Atari platform, we'd have probably given up trying recover the source code for the full demo, but we wondered: if you can develop for the Atari on a modern platform, can you similarly use the modern platform to make it easier to reverse-engineer the source code and data from an Atari binary?

We realised that, even enchanced tools at our disposal, it would proably be a huge undertaking, and we'd probably regret even starting it pretty soon! But we decided to give a try, and if it wasn't working, at least we'd have tried, but if it did work, we would have learned a lot about developing and debugging for the Atari platforms on a modern system!

Hold your seatbelts- let's go!!!!

## Our development setup

We used a Windows laptop with **Visual Studio Code** for our development work. Note that VASM and Vlink have been ported to nearly any platform in current existence, so you're not restricted to using Windows for your dev work.

One good thing about using Visual Studio code is that it allowed us to download an extension for assembling and building Atari source code straight away. It's called **Amiga Assembly** (!!), and as the name suggests, it's primarily for allowing Amiga development on modern systems, but as the Amiga and Atari platforms shared the Motorola 680x0 family of processors, and this extension comes bundled with both VASM and Vlink, this seemed the easiest to set up. VASM can cope with all 680x0 assembly and Devpac syntax (almost- see later!), whilst Vlink can create Atari executables no problem, so it's just a case of configuring the build process. We used VS Code's own tasks to do this. You can see the config we used in `.vscode/tasks.json`. We could probably also add a build process with Makefile as well so *nix systems can do a build too, but for now this setup works for us.

For the emulating and debugging on the Atari side, you can use Hatari itself, as it has an inbuilt debugger. However, for ease of use, we settled on the excellent [HRDB](https://github.com/tattlemuss/hatari) by Steven Tattersall. This is a fork of Hatari, so it contains the same functionality, but it also adds a decent GUI on top of the debugger. If you're used to working with `MONST2` on the Atari, a lot of the layout of the debugger will feel very familiar to you, but it also does a lot of things that would have seemed like the fevered ravings of a madman to old Atari debuggers!

Whether you use plain Hatari or HRDB, one thing you'll need to do is get some Atari TOS ROMS. Hatari does come with a free (as in "speech") ROM binary called Emu-TOS, but you'll want to test with the real TOS just to be sure. (To be *really* sure, also test it on a real Atari!) You'll also want to set up a hard drive in the Atari space that maps onto a folder on the hard drive on your dev setup. One more thing you'll want to do is save a number of configuration files, representing the different configurations of the Atari systems you are wanting to debug on. For example we configured Hatari to emulate a 1 meg Atari STFM running on a mono monitor, and when we were running Mono-Mental through HRDB, we passed it that config file when it started up Hatari.

One thing we found when running HRDB was when you select "Launch" was that the parameters you pass it can be a bit fiddly, and you have to get it exactly right for the best use of the debugger.

* `Executable`- This points to the program file for Hatari that debugger is about to run. you probably don't need to change this.
* `Run Program/Image`- This is the Atari executable you want to debug. This can be a bit fiddly and confusing as the executable has to exist in the hard drive from the standpoint of the Atari platform, but the path used in this parameter is actually the path of the file in *Windows*! This has a knock on effect on the `Working directory` parameter below.
* `Additional options`- This where you can pass options to Hatari. We used this to pass the configuration file to set up a 1 meg STFM in mono mode. eg `-c [PATH TO CONFIG FILE]`
* `Working directory`- If you've filled in the `Run Program/Image` parameter, you'll need to set this parameter to the path of the Windows folder that serves as the Atari hard drive. This is because although Windows knows where the file is, Hatari has to be passed the location of the file, and in Hatari *the path has to be from the point of view of the Atari system!* So, HRDB uses this parameter to work out the *Atari* path to pass to Hatari!

## Initial steps

We wanted to see where we were at in terms of what we could decompile from the demo, so we started by going into Hatari in STFM mode and depacking the demo program using Mike Watson's Mega-Depack program.

The unpacked executable was 267K, (from a packed 122K) which was a slight surprise, as one of the few things we remember about coding the demo all those years ago was that we used the Atomik v3.5 packer to pre-pack the Degas PI3 images we used in the demo, and depack them on the fly in-demo as needed. We did this on the basis that with the amount of pictures used, we'd need to pre-pack them in order for the demo to work on a 1 meg STFM, and given that the images are all single bitplane images rather than interleaved bitplaces, it would probably pack better, saving even more memory, raising the possibility of it even working on a half meg STFM! So if most of the data is already packed, we wouldn't have expected packing the resulting executable would lead it to have been packed by *that* much further. We'd later find out why this was.

In the past, we might have used Easyrider to dissassemble the program, but we couldn't find it anywhere. However, thanks to [DHS's Files Section](https://www.dhs.nu/files.php?t=codingtool), we *could* find TT-Digger v6.2, which was a more recently supported program, and actually did a seemingly better job of dissassembling the program! The caveat with using disassemblers is that they often make "educated" guesses about what's code and what's data, and a lot of the time, they're completely wrong. So you often get disassemble code where the "data" is represented by 68000 code that looks like it would blow up the machine it was running on! There was a lot of that in the dissembled code, but it appeared to make a better go of it than we can remember from Easyrider. (You can see the dissassembled code- all 1383K of it- in `DISSASSMB\MONOMNTL.S`)

When went back to Windows-land and loaded the source into the editor, we noticed straight away it was using code and macros we used other demos which we *did* have the source code for, so could copy over include source files from other demos. There were also common routines such as swapping screens which allowed to do things like a global replace of 'L267382123' with 'swap_screens'.

One important routine we discovered was the routine to depack a packed PI3 to the 'back' screen. The routine is passed the address of the packed data in an address register, so we could look for where this is set, and thereby locate the packed pictures in the source code.

By comparing by comparing with the uncompleted demo code, we could identify the initialisation and restore code. Another piece of code that was easy to spot was the Atomik depacking code, which we replaced with an include to the original source.

The initial top-end of the program is a mass JSRs and BSRs which comprise links to the various parts of the demo. We wanted to identify each part, and where they were in the source, so we'd have a better idea what's going on where. It was at this point we started to use HRDB running on an original (unpacked) copy of the demo. Once we'd fixed the configuration (see above), we could run the demo, and stop it at any point. We started noticing some of the nice touches in HRDB, such as floatable panels, running the computer in fast-forward, being able to see graphics in memory before it appears on the screen, and being able to re-run the demo after a warm reset.

One feature we did use on this test run was the ability right click on a line of code in the disassembly panel and select "Run to here" from the context menu. We used this on each of the JSRs and BSRs to identify the various parts of the demo. On that basis we did a search and replace on the source code labels enabling us to identify the various parts of the demo in the source code.

So, although we'd really only just scratched the surface, we now had a less fearsome and more understandable source to work with! Now, before we started to dive deeper into the code, we had to extract the data from the demo, and replace the data in the source with references to the extracted data.

## Extracting the data

We knew that there were 3 types of data used in the demo:

* Atomik 3.5 packed PI3 images
* Megatizer music files with replay routines
* Bitmap animation sequences

### Extracting the PI3 images

We knew that the PI3 images were packed with Atomik 3.5, and we knew the header for Atomik packed files is a 4 byte string 'ATM5'. So, the logical thing would be to search for 'ATM5', and save a binary file composed of memory from there to the end of the packed file, then run a depacker in Hatari to get the unpacked file.

We could find 'ATM5' strings using the memory search in HRDB, but we couldn't any way of saving a binary file from the memory there, so we decided to go old school, and spin up an instance of Hatari, and load the demo into good old MONST2! Our routine for each file would go like this

1. Tab to the memory panel (Panel 3)
2. Type 'G' for search.
3. Type 'T' text search.
4. Input 'ATM5' for the text to search for.
5. If found, check that it's not the Atomik depack code itself!
6. Note the memory address in the memory panel.
7. Type 'S' for binary save.
8. For the filename, as we don't know what picture it is yet, use a generic name like `pic0nn.pi3`.
9. For the "start,end", use `[ADDRESS FROM STEP 6],[ADDRESS FROM STEP 6]+7d42-1`.
10. Repeat steps for next file.

You might wonder why we're using $7d42 (32066 in hexidecimal) as the length, as this would be the uncompressed length of a Degas Elite PI3 file. Well, the simple answer is: we didn't know the length of the packed files! We just assumed that if we save the binary files as the uncompressed length, we would capture all the packed data, and the depacking routine would ignore any extra data after that. Well, at least, that's what we assumed, but we tested it on a single file, and then ran it through Mega-depack, and it worked!

Another thing to note is that in the "start,end" parameter the "end" value is *inclusive*, hence the "-1" at the end.

After the test file worked, we saved all the other PI3 files we could extract from the demo, and run the directory through Mega-depack in batch mode. We needed to see the files in order to identify them, so we span up *another* instance of Hatari, this time as a mono 1 meg ST, and viewed the images in Degas Elite. (Imagine doing this sort of thing in the old Atari days!)

After identifying the images, and renaming them, we re-run the demo on the debugger to see if there were any we missed out. It turns we did miss one out! But we got it eventually from the MONST2 Hatari instance.

Now we had all 18 (!) PI3 files unpacked, (They're in `GRAPHICS\UNPACKED`) all we had to do was repack them for use in the demo source. We had a bit of nostalgia watching Atomik v3.5 crunching away in batch mode! Of course, we cranked up the CPU clock in that instance of Hatari to make it quicker!

Surveying the results of the packed files, (They're in `GRAPHICS\PACKED`) it seems we made a good call with pre-packing them for the demo. 18 unpacked PI3 files, totalling a size of 563KB, is now 18 *packed* PI3 files, totalling a size of 82.3K! The entire "MONO-MENTAL" title sequence of 4 PI3s is just 7K in total, and the "Doctor Who" starfield is just 1K!

Of course, this was plain sailing compared to actually replacing the pictures in the source code! First, we had to know where the pictures were being referenced. We were able to do this by looking for where the picture depack routine we being called, and from there identify the label for the picture data being referenced, and replacing the label with something readable. There was one case where a picture was being depacked to a different screen, and we almost missed that one!

Once the labels were changed to readable ones with meaningful names, we replaced the data/decompiled source versions of the pictures in the source code with a simple `incbin` pointing to the relevant file. Well, okay, that sounds a bit simpler than it actually was! Adding an `incbin` is simple, but imagine having then to get rid of hundreds of lines of source code with inscrutable instructions like `dc $3452` and `bvs.w T66293462`! And if we never see `dc $ffff` again, it'll be too soon!

So, as you can imagine, integrating the picture data into the source code took a while!

### Extracting the music

Thankfully, this was much easier. We did have some of the music from the incomplete demo, but we weren't sure if it was up-to-date. In any case, there was **one** piece of music we *didn't* have, (The "Test Card" music.) so if we were going to have to extract *that*, we might as well extract the others, and have the most up-to-date versions!

We knew the obvious solution would be to run a music ripper program on the uncompressed demo in Hatari, and we were right! Well, sort of, as Dodgy Music ripper couldn't find a thing! However, we were luckier with the Adrenaline Ripper, which found all 5 (!) of them! One nice touch in their music ripper section is that if it finds music, you can listen to a preview of it, enabling you to identify the song and save it with a meaningful filename!

If you're thinking *'Wait a sec, isn't there only 3 pieces of music in the demo?'*, there's an additional music file for the 'static' at the start of the demo, and another for the 'crash' at the end!

One thing that made us laugh was that in another section of the Ripper, we found a section for searching for Atomik packed data, and saving it unpacked! We could have just used the Adrenaline Ripper to unpack our PI3 pics!

Of course, we had to go through the same rigmarole as with the pictures when it came to slotting them into the source code. Fortunately the music files are only referenced a couple of times in the code each, so it was easier to fix the labels to meaningful ones. Also, the music files are next to each other in the code, which made it much easier to replace the source with `incbin` replacements.

### Extracting the bitmaps

We were expecting this to be the most difficult bit of the extraction, as we were expecting the animations to be in a binary bitmap form, and we'd have to spend ages analysing the code to work out the dimensions of the animation frames, and then going into MONST2, and binary saving them off. However, that's not exactly what happened!

We were mulling over how to do the extraction whilst we were still in the Adrenaline Ripper. We had a look at the screen ripper section, and noticed we could view the animation frames from the demo as uncompressed bitmaps in memory. Of course, it's showing a hi-res bitmap on 4 bitplane screen, but we found we could switch to a 2-plane display. Of course, the Ripper doesn't do hi-res, but what we did notice was that when we viewed the screen memory from the start of the animation frames, that the series of bitmaps filled the whole of the screen, implying it was a block of exactly 32000 bytes!

That was strange enough, but there were three of these 32000 byte blocks of animation frames, each with three frames, next to each other in the data of the demo. Even odder, there appeared to random bytes either side of these blocks that appeared to do nothing! Maybe header data? We looked back the source, and it certainly wasn't real code!

The penny dropped when looked at one example of "random" bytes before a bitmap block in HRDB's memory panel, and we realised it was 34 bytes long- the length of the header of a Degas Elite PI3 file!

*"Is this **really** just a couple of uncompressed PI3 files `incbin`'d into the code?!?!"* we thought, so we put that to the test by saving off one of the blocks using the same method in MONST2 we used to save the packed PI3s, then we loaded the result into Degas Elite, and it worked! It was a PI3 file after all! The reason why packing the program still made a large difference to the size was that there were still 3 uncomprossed PI3s in the binary.

As to *why* we used uncompressed PI3 files for the animations, well, we probably last looked at the source code the night before it's release in April 1998, but we can guess that it's something to with the fact that the demo is in hi-res mono, and the sort of tools that you would use to create animation bitmaps only cater to colour displays, particularly lo-res.

A more pertinant question might be: why were PI3 files *uncompressed*? Why didn't we do the compressing trick we did with all the other pictures, and uncompress on the fly to a scratch screen memory bloc, and copy the animations onto the screen from there? Well, your guess is as good as ours! Maybe we left them uncompressed as we could access them directly *in situ*, and the "Credits" screen would require *two* scratch screens, raising memory concerns. Maybe we were worried that we wouldn't have enough processor time to unpack the screens to memory. Or maybe we were running out of time, and just went with the quick and dirty route!

Whatever the reason, it was much easier than we expected to extract the bitmaps! Now, all we had to do was replace their equivalents in the source code with `incbin`s the files: three blocks of junk source representing 32K of binary to get rid of- argh! Still, the files were next to each other in memory, so that made things easier. After that, it was a matter of checking the reference to the code that was using the bitmaps, and cleaning it up.

## Getting the code to compile

Now that we'd extracted all the data, the resulting source code was now a fraction of it's original disassembled length, and we started moving in on cleaning up the code as much as possible before we'd even start debugging it. A lot of the code we recognised from the macros we were using before, so we could convert that code to the macros. Other parts of the code, we could deduce appropriate label names from the code and the demo part it was executing. This took quite a lot of time to go through the various demo parts in order to clean up the code. We had a backup of the disassembled code for reference in case we found we'd deleted an important bit of code or data!

Our goal was to get as much of the code looking right before debugging. One major part of this goal was that it had to be compilable, so that we could start debugging it!

One thing we noticed was that the Amiga Assembly module automatically runs VASM on your code as soon as you save any changes, which means you can spot any obvious syntax errors as soon as possible. However, VASM, is only part 1 of the build process, and some errors only crop up when you run a full build, when Vlink turns your compiled code into an Atari exectuable!

We were seeing a lot of reference errors, where something in the code is pointing to a label Vlink can't find. Oddly enough, all these references were to local labels. We often used local labels in our subroutines for stuff like loops or decision branches. Oddly enough, these errors were not happening in other subroutines with local labels. We eventually determined that it was due to a timing macro that creates it's own loop complete with generated label. On Devpac this label would be compiled as a local label. However, VASM compiles it as a global label, which breaks local labels either side of it! Once we worked that out we changed the local labels to global ones in the affected subroutines, and successfuly compiled the source code to an Atari executable!

There might be some config in VASM or source code syntax where we can make the macro compile a local label, but for now, we have a buildable source code!

Now to get it running on an Atari...

# More soon!