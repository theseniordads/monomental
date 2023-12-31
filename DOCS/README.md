# "Mono Mental" recompilation notes

By **THE SENIOR DADS**

*Started: 2023-08-11*

We've recently been adding the source code of our old Atari demos to our [GitHub page](https://github.com/theseniordads), as part of our testing out using modern dev systems to create new Atari code! These days you can use a modern dev enviroment on Windows, Mac or Linux to crank out code, which you can then assemble, using [VASM](http://sun.hasenbraten.de/vasm/) and [Vlink](http://www.compilers.de/vlink.html), to an Atari excutable, which you can then run on an Atari emulator such as [Hatari](https://hatari.tuxfamily.org/)!

In the majority of cases, we had the source code to hand, and all we really had to was check it could assemble on a modern system, and the resulting executable could run on Hatari. VASM and Vlink are more or less compatible with the sort of assembler code you would write in Devpac in  the old Atari days, but there are one or two syntax things that you may have to change in order to get the code to assemble. (We'll mention those later.)

**Mono Mental** was a different case altogether as we didn't have the source code for the full demo, only an early version with the just the opening titles and an early version of "Yogie Baird" screen completed! (You can find this in the [`OLD`](https://github.com/theseniordads/monomental/tree/main/OLD) folder.) It's interesting in it's own right, as there's a lot of "what if?"s in the demo at this stage, but it's certainly nowhere near the complete demo as released!

If we were doing this on the Atari platform, we'd have probably given up trying recover the source code for the full demo, but we wondered: if you can develop for the Atari on a modern platform, can you similarly use the modern platform to make it easier to reverse-engineer the source code and data from an Atari binary?

We realised that, even with the enchanced tools at our disposal, it would probably be a huge undertaking, and we'd probably regret even starting it pretty soon! But we decided to give a try, and if it wasn't working, at least we'd have tried, but if it did work, we would have learned a lot about developing and debugging for the Atari platforms on a modern system!

Hold your seatbelts- let's go!!!!

## Our development setup

We used a Windows laptop with **Visual Studio Code** for our development work. Note that VASM and Vlink have been ported to nearly any platform in current existence, so you're not restricted to using Windows for your dev work.

One good thing about using Visual Studio code is that it allowed us to download an extension for assembling and building Atari source code straight away. It's called **Amiga Assembly** (!!), and as the name suggests, it's primarily for allowing Amiga development on modern systems, but as the Amiga and Atari platforms shared the Motorola 680x0 family of processors, and this extension comes bundled with both VASM and Vlink, this seemed the easiest to set up. VASM can cope with all 680x0 assembly and Devpac syntax (almost- see later!), whilst Vlink can create Atari executables no problem, so it's just a case of configuring the build process. We used VS Code's own tasks to do this. You can see the config we used in `.vscode/tasks.json`. We could probably also add a build process with Makefile as well so *nix systems can do a build too, but for now this setup works for us.

For the emulating and debugging on the Atari side, you can use Hatari itself, as it has an inbuilt debugger. However, for ease of use, we settled on the excellent [HRDB](https://github.com/tattlemuss/hatari) by Steven Tattersall. This is a fork of Hatari, so it contains the same functionality, but it also adds a decent GUI on top of the debugger. If you're used to working with `MONST2` on the Atari, a lot of the layout of the debugger will feel very familiar to you, but it also does a lot of things that would have seemed like the fevered ravings of a madman to old Atari debuggers!

Whether you use plain Hatari or HRDB, one thing you'll need to do is get some Atari TOS ROMS. Hatari does come with a free (as in "speech") ROM binary called Emu-TOS, but you'll want to test with the real TOS just to be sure. (To be *really* sure, also test it on a real Atari!) You'll also want to set up a hard drive in the Atari space that maps onto a folder on the hard drive on your dev setup. One more thing you'll want to do is save a number of configuration files, representing the different configurations of the Atari systems you are wanting to debug on. For example we configured Hatari to emulate a 1 meg Atari STFM running on a mono monitor, and when we were running Mono Mental through HRDB, we passed it that config file when it started up Hatari. We also set up other configrations. For example, you'll want to set up config for an ST with a colour monitor in medium res if you want to use a lot of the Atari native coding tools like MONST2.

One thing we found when running HRDB was when you select "Launch" was that the parameters you pass it can be a bit fiddly, and you have to get it exactly right for the best use of the debugger.

* `Executable`- This points to the program file for Hatari that debugger is about to run. you probably don't need to change this.
* `Run Program/Image`- This is the Atari executable you want to debug. This can be a bit fiddly and confusing as the executable has to exist in the hard drive from the standpoint of the Atari platform, but the path used in this parameter is actually the path of the file in *Windows*! This has a knock on effect on the `Working directory` parameter below.
* `Additional options`- This where you can pass options to Hatari. We used this to pass the configuration file to set up a 1 meg STFM in mono mode. eg `-c [PATH TO CONFIG FILE]`
* `Working directory`- If you've filled in the `Run Program/Image` parameter, you'll need to set this parameter to the path of the Windows folder that serves as the Atari hard drive. This is because although Windows knows where the file is, Hatari has to be passed the location of the file, and in Hatari *the path has to be from the point of view of the Atari system!* So, HRDB uses this parameter to work out the *Atari* path to pass to Hatari!

## Initial steps

We wanted to see where we were at in terms of what we could decompile from the demo, so we started by going into Hatari in STFM mode and depacking the demo program using Mike Watson's Mega-Depack program.

The unpacked executable was 267K, (from a packed 122K) which was a slight surprise, as one of the few things we remember about coding the demo all those years ago was that we used the Atomik v3.5 packer to pre-pack the Degas PI3 images we used in the demo, and depack them on the fly in-demo as needed. We did this on the basis that with the amount of pictures used, we'd need to pre-pack them in order for the demo to work on a 1 meg STFM, and given that the images are all single bitplane images rather than interleaved bitplanes, it would probably pack better, saving even more memory, raising the possibility of it even working on a half meg STFM! So if most of the data is already packed, we wouldn't have expected packing the resulting executable would lead it to have been packed by *that* much further. We'd later find out why this was.

In the past, we might have used Easyrider to dissassemble the program, but we couldn't find it anywhere. However, thanks to [DHS's Files Section](https://www.dhs.nu/files.php?t=codingtool), we *could* find TT-Digger v6.2, which was a more recently supported program, and actually did a seemingly better job of dissassembling the program! The caveat with using disassemblers is that they often make "educated" guesses about what's code and what's data, and a lot of the time they're completely wrong. So you often get disassembled code where the "data" is represented by 68000 code that looks like it would blow up the machine it was running on! There was a lot of that in the dissembled code, but it appeared to make a better go of it than we can remember from Easyrider. (You can see the dissassembled code- all 1383K of it- in [`DISSASSMB\MONOMNTL.S`](https://github.com/theseniordads/monomental/blob/main/DISSASSMB/MONOMNTL.S).

When went back to Windows-land and loaded the source into the editor, we noticed straight away it was using code and macros we used in other demos which we *did* have the source code for, so could copy over include source files from other demos. There were also common routines such as swapping screens which allowed us to do things like a global replace of labels like 'L267382123' with 'swap_screens'.

One thing we were suprised at was that we didn't include a "secret message" in the code like we did with "[Air Dirt](https://github.com/theseniordads/airdirtdemo/blob/main/MAIN.S)" or especially "[Xmas Card '97](https://github.com/theseniordads/xmascard97/blob/main/MAIN.S)"! We must have been running out of time if we didn't do that!

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

Now we had all 18 (!) PI3 files unpacked, (They're in [`GRAPHICS\UNPACKED`](https://github.com/theseniordads/monomental/tree/main/GRAPHICS/UNPACKED)) all we had to do was repack them for use in the demo source. We had a bit of nostalgia watching Atomik v3.5 crunching away in batch mode! Of course, we cranked up the CPU clock in that instance of Hatari to make it quicker!

Surveying the results of the packed files, (They're in [`GRAPHICS\PACKED`](https://github.com/theseniordads/monomental/tree/main/GRAPHICS/PACKED)) it seems we made a good call with pre-packing them for the demo. 18 unpacked PI3 files, totalling a size of 563KB, was now 18 *packed* PI3 files, totalling a size of 82.3K! The entire "Mono Mental" title sequence of 4 PI3s is just 7K in total, and the "Doctor Who" starfield is just 1K!

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

As to *why* we used uncompressed PI3 files for the animations, well, we probably last looked at the original source code the night before it's release in April 1998, but we can guess that it's something to with the fact that the demo is in hi-res mono, and the sort of tools that you would use to create animation bitmaps only cater to colour displays, particularly lo-res.

A more pertinant question might be: why were PI3 files *uncompressed*? Why didn't we do the compressing trick we did with all the other pictures, and uncompress on the fly to a scratch screen memory bloc, and copy the animations onto the screen from there? Well, your guess is as good as ours! Maybe we left them uncompressed as we could access them directly *in situ*, and the "Credits" screen would require *two* scratch screens, raising memory concerns. Maybe we were worried that we wouldn't have enough processor time to unpack the screens to memory. Or maybe we were running out of time, and just went with the quick and dirty route!

Whatever the reason, it was much easier than we expected to extract the bitmaps! Now, all we had to do was replace their equivalents in the source code with `incbin`s the files: three blocks of junk source representing 32K of binary to get rid of- argh! Still, the files were next to each other in memory, so that made things easier. After that, it was a matter of checking the reference to the code that was using the bitmaps, and cleaning it up.

## Getting the code to compile

Now that we'd extracted all the data, the resulting source code was now a fraction of it's original disassembled length, and we started moving in on cleaning up the code as much as possible before we'd even start debugging it. A lot of the code we recognised from the macros we were using before, so we could convert that code to the macros. Other parts of the code, we could deduce appropriate label names from the code and the demo part it was executing. This took quite a lot of time to go through the various demo parts in order to clean up the code. We had a backup of the disassembled code for reference in case we found we'd deleted an important bit of code or data!

Our goal was to get as much of the code looking right before debugging. One major part of this goal was that it had to be compilable, so that we could start debugging it!

One thing we noticed was that the Amiga Assembly module automatically runs VASM on your code as soon as you save any changes, which means you can spot any obvious syntax errors as soon as possible. However, VASM, is only part 1 of the build process, and some errors only crop up when you run a full build, when Vlink turns your compiled code into an Atari exectuable!

We were seeing a lot of reference errors, where something in the code is pointing to a label Vlink can't find. Oddly enough, all these references were to local labels. We often used local labels in our subroutines for stuff like loops or decision branches. Oddly enough, these errors were not happening in other subroutines with local labels. We eventually determined that it was due to a timing macro that creates it's own loop complete with generated label. On Devpac this label would be compiled as a local label. However, VASM compiles it as a global label, which breaks local labels either side of it! Once we worked that out we changed the local labels to global ones in the affected subroutines, and successfuly compiled the source code to an Atari executable!

There might be some config in VASM or source code syntax where we can make the macro compile to a local label, but for now, we have a buildable source code!

Now to get it running on an Atari...

## Debugging the demo

We tried to modify our `.vscode/tasks.json` to copy the compiled binary to the Atari hard drive each time it was built, but it just wasn't working, and any documentation or forum talk about it on the internet was as helpful as going to someone in the street and asking them how to get to the nearest railway station, and them replying: *"Oh it's easy! Just fold the fabric of spacetime, and it'll come to **you**!"*! So in the end, we just changed the build directory in the Amiga Assembly settings to go to the Atari hard drive, which is probably not the best way to go about it, but at least it worked for now. We could now point HRDB to that executable for debugging purposes.

What we decided then was to comment out all the calls to the demo parts, and just uncomment them one at a time as we went through the debugging process. We were also thinking about splitting the source into a series of demopart includes. We were aiming for a build that is faithful (almost!) to the original binary, but given the original source almost certainly no longer exists, and that we were aiming for VASM/Vlink compatibility, aiming for *source code* fidelity would be a bit silly!

### Save and restore routines

First thing we wanted to check, before any of the demo parts, was the save and restore routines. Can the program show the text intro, check for a mono monitor, and then exit cleanly?

Well, we gave a go, and straight away we noticed something wrong, and it was from the most unexpected place- the text intro! In the last line, in the word "space", "e" is replaced with "£". However the ASCII character code for "£" [on the Atari is different](https://en.wikipedia.org/wiki/Atari_ST_character_set) from the UTF-8 the source code is saved as, so it compiled as UTF-8 "£", mucking up the last line of the text intro! We fixed that by replacing the "£" with the Atari ASCII character code for "£". We also check for the monitor type, and that was the Save routines ready to go!

On the restore routines, the only problem we found that the code didn't take too kindly to stopping a piece of music it hadn't even started playing yet! However, ever we commented that line out, restore routines worked fine.

### "Present..." screen

An important milestone, as it's the first time the demo starts playing music and depacking a picture and displaying it! So we were a bit concerned when it did neither upon first run! The problem seemed to be occuring when the music was first being initialised and the processor jumped into the initialisation routines of the music file, and swiftly disappeared down a rabbit hole! We looked at the music file in the memory panel of HRDB, and thought *"Hmmm, that doesn't look like the 3 BRAs we were expecting at the start of the music file!"* Was the file corrupted? When we resetted and looked again at the music file in the memory panel again, it appeared to be fine *before* we ran the program, so something must have corrupted it in the meantime!

Sure enough, we tracked it down to the screen depack routine that was run before the music was initialised. It appeared to be depacking the screen all over the music files! But why was it doing this, when it never did this before? We looked the depack code include, (The standard Atomik depack routine included with the packer.) and realised it was in it's default mode of depacking data to the same place as the packed data! As the "Presents..." pic was close to the music files in the program data, that means it was corrupting those files before they had a chance to run!

As soon as we changed the mode in the Atomik source file so that it would depack to the address given to it in `a1`, and re-built, the "Present..." screen worked first time! Phew!!!

### The "Test Card" screen

No crashes here, but we noticed a couple of things wrong straight away. First was that the font used by our `font_string_mono` routine appeared corrupted! The second was that static music didn't appear to be playing! We actually noticed this when we were coding the original version- sometimes the static section was silent- so we weren't too worried about this one. We were more worried about the font corruption, as that was used all over the demo!

We were a bit surprised at this, as we were using the same `CRAPFONT.DAT` font we'd been using since "[Air Dirt](https://github.com/theseniordads/airdirtdemo)", and the font data on the recompiled demo appeared to be identical to the original demo when we looked it in the Memory Pane in HRDB, so we suspected the problem might be in our recreated code! We looked at the code, and it looked like there was nothing wrong with it, and it appeared identical to the disassembled code we saw when looked at the original demo in HRDB, so what was going on?

We found out when we looked at our new assembled code in HRDB. Our routine used a `REPT` block of `move.w`s to write the font data to the screen buffer, using the assembler's own built in variables to calculate the screen offsets to add to the address register handling the screen buffer. In each repeat, the offset would be increased by increasing the variable. However, looking at the assembled code, the variable wasn't being increased, and was stuck at zero! So every line of font was being written to the top line of each character!

This was really wierd as the same trick was used almost identically in another routine, and we could see from the compiled code in HRDB that it *was* compiling correctly! We thought: *"Instead of faffing about trying to work out what's going on, why don't we just copy over **that*** code and amend it, see if it works?"* So we commented out the not-working code, copied over the working code, amended it, compiled it- and it worked!!

We thought *"Phew!"*, and got ready to clean out the not-working code. It was only then that we realised that the only difference between the working and the not-working code was that the bit that increased the offset variable was `i set i+80` in the working code, and `i set i + 80` in the not-working code! The assembler had ignored anything after the space before the `+`, and had just processed it as `i set i`, meaning `i` was stuck at zero!

### "Mono Mental" titles and intro pics

You might wonder why we grouped these two together. Well, the titles screen exit after it displays the last screen so the next screen (In this case the intro pics screen) can prep it's stuff! Also the intro pics screen just displays two pics! How hard can that be?

One thing we noticed was that the music appeared to be slightly corrupted! Thank goodness we still had the original music file to hand! We slotted it in, and it was as good as new! (Thank goodness the "Test Card" music wasn't similarly corrupted!)

As you can expect, the intro pics section was easy! Well, apart from finding out we'd missed out the line of code needed to display the second picture!

### "Yogie Baird" screen

It worked first time!!!! We were dreading this one, and all for nothing! We spent more time typing this sentence than we did debugging the screen!

### "Codearokie" and "Basil" screens

We were also dreading this one too, as there was so many fiddly bits with text pointers and timing tables! But it turns out that only the Codearokie "frame" data needed debugging, and it was mostly small typos affecting the positioning and timing, and there wasn't even much of that! The only real biggie was some missing data for the last frame, which the 68000 processor interpreted as *"sit around and do nothing for a very long time"*!

### "Steptool and Son" screen

Worked first time, but we were less surprised as this uses the code from the "Yogie Baird" screen!

### "Doctor Who" screen

Again, we were dreading this one, and it appeared we were right to do so, as the starfield only partially appeared, and the screen locked up after a while!

However, it turned out to be just a couple of typos in our code that caused both, so it was actually easy to fix!

### "Prodigy Tribute" aka "Smack My Bitch Up" screen

Ran first time! To be honest, this was quite a simple screen, so we weren't expecting any major problems here.

### "Tri-di Donut" screen

Another biggie, and upon our first trial run, it didn't appear at all! So we suspected something had gone wrong right at the prep stage. Sure enough, we found a couple of typos that caused a crash. Once we fixed those, everything worked fine!

### "Greetings" screen

Another potential biggie, as we were expecting the similar issues to the "Codearokie" screen, with some possible typos in the text and positioning! But in fact, the first thing we noticed upon first run was that it crashed immediately after displaying the first greet!

It turns out the greets table was missing the timing data that the original demo had, so the first greeting would display fine, but after that the pointer to the greetings table would be pointing to some crashable data!

Luckily after a look at the disassembled code, we were able to extract those values, and put them into our code, (It was mostly the same values, anyway!) and the screen worked!

### "Man From UNCLE" screen

Worked perfectly, even down to the unexpected return of the donut!

### "Mono Mental" titles- again!

We needed to the check the second appearance of the titles didn't mess anything up- and it didn't!

### "Credits" screen!

The only bit we found we got wrong here was copying the correct width of the bitmap for the crew logos, but that was an easy fix!

### The ending aka "White Dot" screen

This initally looked good when it started, but then we found that the fake crash ending actually crashed for real! We found that this was another silly typo where we needed to do an `even` after some data so it wouldn't cause an address error!

Another small change was that the crash music (Which was a combination of our "standard" crash music, and playing the main music in super fast-forward!) was that the crash was ending on the wrong note! We found that re-initialising the main music file after the crash music had finished fixed things.

### Fixing the "static" music

Now that all the demo parts were working, we just need to fix the problem of the "static" music not playing.

We initally suspected that with the Adrenaline Ripper not ripping the music the right way for the main music (To be fair, it appeared to recognise it as a different format of music to Megatizer.), then the same might be true for the "static" music. So, given that it wasn't a large piece of music, we could probably just go into MONST2 in an instance of Hatari, load in the original demo, and rip the music from there.

So, we noted all the addresses of the music files in MONST2 as we knew they were all bunched together in the data, so we figured that if it's inbetween other music files, we can work out it's length! Unfortunately, it was right at the *end* of the music files! Luckily the memory address of old screen pointer is saved in the address right after the end of the music files, so we were able to get the length that way.

When we looked at the length of the ripped music, we were a bit concerned as it was 4K long, rather than the Adrenaline Ripper version, which was 10K! But we played it in Megatizer, and it seemed okay. So we plugged the newly ripped music in- still nothing! We then noticed the call to play the music file was `jsr mus_static + 8`, and thought *"Ono!! It can't the assembler being picky about spaces again?!?!"* So we changed it to `jsr mus_static+8`, and it worked!

## Cleaning up

Now we had a working version of the demo, it was just a matter of cleaning up and annotating the remaining code! We also found there was a lot of crap code left by the dissassembly, which took up a lot of the space in the source. Once we cleared that up, and hived off the various demo parts into their own include files, the source code was a whopping 12.3K with 40.1K of include files, 52.4K in total. When you think that we started off with a 1383K disassembly source code file, that's quite a reduction, escpecially with the amount of commenting we added to the source code!

So now all we had to do was compile the code without labels to an executable, and we'd have a version of the demo that was as close to the original as possible! One thing we noticed was that the compiled version was 261K whilst the original was 267K, so maybe we cleared out some code that was in the original but not used, or somehow the VASM assembly was more optimal than Devpac. (Probably unlikely, since how can you make assembly language more optimal than it already is?) Either way, the newly compiled version, which we have decided to call the "Remastered" version, runs exactly like the original, and is as close as possible to the original binary. After jumping into Hatari, and running the new version through Atomik packer v3.5, we ended up with a 115K executable (As opposed to the 122K original version), which you can see [here](https://github.com/theseniordads/monomental/tree/main/COMPILED/REMASTER).

After testing the result on Hatari, we had to clear up one last thing: although we had designed for and specified in our `MONOMNTL.TXT` that this demo was for a 1 meg STFM with mono monitor, given that the demo used up around 354K of memory (which includes 3 screen buffers worth of memory), would it also work on a half-meg? Way back when we coded the original demo, we all had memory expanded STs, and we weren't going to open up our computers (No mean feat, if you've ever tried this with an Atari 16 bit!) and remove memory chips just to test our demos! And none of our Atarian friends had anything less than a meg of memory on their computers, so we just aimed for a 1 meg target, given the amount of graphics we were using, with a half-meg target as a nice-to-have.

Of course, thanks to Hatari, you can do the virtual equivalent of opening up your Atari STFM and removing memory chips, so we configured Hatari as a half-meg STFM on a mono moniter, and ran the demo, and it worked just fine. Intrigued, we ran the original version on the same configuration- also fine!

So "Mono Mental" was *always* half-meg compatible!

## "Remixing" the demo

Now we had a version of the source that compiled an (almost) exact copy of the original demo. But we weren't going to stop there! One annoying thing we noticed whilst debugging was that the timing of the screens was slowly getting out of sync as the demo progressed. We noticed this when running the original demo, so it wasn't a result of our recompilation. Now, if you've seen our "Air Dirt" and "Xmas Card '97" demos, you'll know how picky we are with timing! So it was really super annoying to see it slowly fall apart in this demo, and we realise that it it was probably *always* like that when you view it on it's intended platform!

Also, we wanted to fix that message you get when you try and run the demo on a colour monitor! It's bad enough that you get a nasty message, but having having a situation where it appears to exit cleanly to the desktop, and then the computer crashes when you start moving the mouse is taking the piss! In fact, is there a reason the message appears *after* the initial text intro has happened?

Finally, we were wondering about the 96K worth of unpacked PI3s in the demo. Could we have worked out a way to pack them and use them in the demo if we had the time?

### Branching for the "remix" version

The good thing about source control is that you can preserve the original code, and do a different version in another branch. So the the first thing we did was create branches for the "remaster" and the "remix" version we were about to start working on.

### Fixing the colour monitor message

This was fairly easy to fix. The code to check the monitor resolution was for some reason in the middle of the "init" sub routine, so we moved it to the start of the routine, then in the routine that prints the cheeky message and waits for a keypress, instead of the `clr.w -(a7)` trap #1 to exit the program (!), the code now `bra`s to a new label `end_demo` in the main demo hub, which bypasses the rest of the demo and exits cleanly to the desktop.

Now you may be thinking: *"Hang on, the stack still has the return address for `init` on it, so won't it crash when it returns?"* Well, yes, that would something to be wary of, but we're using our own custom stack for the demo, and the first thing that happens after jumping to `end_demo` is a restoration of the system stack, so it doesn't matter!

### Fixing the timing

Just so you know, we **never actually developed or tested this demo on a mono monitor**!!! At the time, we didn't have one, so We used a colour display with a mono emulator for development and testing! And we didn't know anyone with a mono monitor! So our original timing was probably pushed slightly longer than needed due to the comparatively slow mono emulator, which also ran on a 50Hz display. However, it wasn't *that* far out, as we were basing our timing on the music, which was running on Timer D to a 50Hz interrupt, so it could play normally on a 71HZ mono display.

One thing that we did notice was that the shorter values were more accurate, and that it was the longer ones that were more out, and over the course of the demo that added up to a noticable lag between the music and visuals, adding up to just over a bars worth of music by the end of the demo!

The first bit where were noticed the timing was going out was the intro text to the "Yogie Baird" screen, where the text was displaying for just a little bit too long! Fixing that actually fixed the timing for the "Yogie" screen, and the following "Codearokie" screen! The next time that had to be fixed was the "Basil" screen going on a little bit too long. Fixing this fixed most of the demo up to and including the "Tri-di Donut"! The next tweak was the timing on the "Greetings" screen, which *almost* fixed the time of the rest of the demo! All that needed was a small tweak to the "Man from UNCLE" screen, and the timing was perfect! Ironically, this was the time to find that there was a bug in the timer code here, as it didn't test for the possibility of a negative time value when it was checking if the timer had expired! Still, it was an easy fix!

### Packing the unpacked PI3s

We knew this would be a bit more tricky than the other enhancements, and we were right! We knew we'd need a fourth screen buffer, and then we realised that as the two screens the bitmaps are used in already use screen buffer 3, for the "Credits" screen we'd need a *fifth* screen buffer to store the additional crew bitmaps! Would this be possible on a half-meg STFM? We worked out that, given the unpacked PI3s took up ~96k of memory in total, as long as the packed versions took up 32K or less in total, that meant that enough memory would be freed up for two additional screen buffers. As it happened, when we packed the PI3s, they took up 8K in total! So we could add the extra screen buffers, and still save 24K of memory!

The question then became: do we have the time to unpack the PI3s on the fly? If you see the "Basil" screen, the picture is depacked to the screen currently being displayed for a joke, so you can see how long the depacking takes! In order to do the depacking for the bitmaps, we'd have to do the depacking whilst the demo is running, but not doing anything, such as when it's waiting for the timer to run out- and we'd have to be pretty strategic about it!

The "Doctor Who" screen comes right after the "Steptool and Son" screen, and there wasn't any time during that screen to do any unpacking, but before *that* is the "Basil" screen, which has a long enough pause to do the unpacking. So we added additional code that depacks the "Tardis" bitmap to screen buffer 4 in the background, and resetted the sprite pointers to point to screen buffer 4, and it worked first time! The irony that the "Basil" screen now shows a picture being depacked to screen and then secretly depacks *another* picture to memory is not lost on us!

The "Credits" screen would be a bit more difficult, and we'd have to find time to depack *two* PI3s, and the only obvious pause is during the "Greetings" screen, when the bombs show up! Would that be enough time to depack two pics? Turns out it was more than enough time, and so we added the depacking code to the "Greetings" screen, and pointed the sprite pointers to screen buffers 4 and 5, and that also worked first time!

### Final touches

As a result of the bitmaps now being packed, the *unpacked* executable shrunk from 261K to 173K! And despite the usage of two new screen buffers, it took up 28K less in memory! We then found you could define multiple areas in the source code as `text`, `data` or `bss`, sections, and VASM would accept it! (We expect that this was always the case with the likes of Devpac or similar Atari assemblers.) That meant we could define a lot of the internal buffers used as `bss`, and further shrink the executable to 167K!

There was one funny error along the way though: we accidently removed the `rts` from the end of the "Tridi Donut", so it went straight into the next bit of code, and so that screen ended, and then suddenly the music stopped and "Seniors Dads present..." appeared, complete with fanfare! And after that, the demo continues as if nothing happened, albiet to the dying strains for the fanfare!

One thing that we did notice was that all that packing and optimisation meant that the ending "Crash" screen, which copied from an area of the demo code, which happened to include the uncompressed bitmaps, and the words "The end?" in a memory buffer, now was just a load of random memory dumped to the screen!

Then we had an evil thought: *if we've saved 28K of memory, do we have enough memory for a compressed screendump of the original ending, and display that instead?* We worked out that if you ran the original demo in MONST2 until the bit after the end where interrupts were restored, the area of memory that was copied onto screen during the "crash" section was unaltered, and we could binary save 32000 bytes from that address into a binary file. We imported the uncompressed file into our new code, and it worked! Of course, being who we are, we added fake Degas Elite headers either side of the bitmap in the code, so we could run the new code through MONST2, and save off the bitmap as a Degas Elite PI3 file!

Putting the PI3 through Atomik resulted in the most disappointing of the packing results, with the packed version being a whopping 15K, (!) however, being able to re-use the picture depacker code actually resulted in a reduction in the code size! The size of the compiled exectuable was now 181K, which is still 86K less than the uncompressed original *and* it's memory footprint is nearly 17K less!

The final question: now that all the uncompressed bitmaps are compressed, and all the `bss` sections added, how well would the executable compress with Atomik? Would there be anything left to compress? We knew that there were some `REPT` code blocks which whick could be easily compressed, and the music files were uncompressed, but there was also an extra 15K of not-easily-compressible data to pack!

However, after running the executable through Atomik, we found that it was still able to pack the executable down to a respectable 125K, compared to the 122K of the original and the 112K of the "Remastered" version. It might seem disappointing that the "remix" version is 3K bigger packed than the original, but the unpacked "remix" executable is **68%** of the size of the unpacked original (The acutal code is just under 32K!) and uses less memory, and still fits in more data! When you consider there's **688K** of graphics data plus 3 main pieces of music, and it *still* works on a half meg ST, that's a pretty decent acheivement! Well, that's how we justify it anyway...

You can download the "Remix" version [here](https://github.com/theseniordads/monomental/tree/main/COMPILED/REMIX)...

### One *final* bug!

The "remix" version had one final surprise for us though! The demo exited to the desktop fine when we ran it through the HRDB version of Hatari, but when we ran it through a plain vanilla version of Hatari, when it exited to the desktop, it somehow didn't restore the screen address correctly, and the screen was corrupted! We tried running the "remastered" version and the original version through the same instance of Hatari, and both exited cleanly with no problems, so it must have been a bug introduced in the "remix" version! The only reason we hadn't noticed it before was that in HRDB it runs the demo as a "AUTO" program, before the desktop is even loaded, so it initialises the screen address *after* the demo has exited. Or at least that's what we initially thought!

When we were going though the code and changing all the clear bits of memory we were using in the demo to `bss` sections, we included the custom stack we were using in the demo. So we wondered if that was being corrupted in some way since as a `bss` section, it wouldn't be automatically cleared before use. Testing that, we changed it back to a code segment, ran the demo, and it worked!

We thought *"Phew! That was easy!"* and started preparing a new release of the remix! We used this release as an opportunity to add a secret message to code rippers that we didn't include in our original release. So, we did that, and ran a test build of the demo through HRDB just to check. Just as well we did, because the bug was back again!

If it wasn't our custom stack being corrupted that was causing the problem, what was? The only change we had made was to have added some `dc.b` statements for the hidden message, we'd made sure there was an `even` after the last one, and in any case, this addition wouldn't have corrupted the program by itself!

We used the fact that we could now see the bug when running in HRDB to debug which part of the demo was causing the problem. We established that running just the save and restore routines was fine, but running any ofther part of the demo, even the "Presents..." screen, caused the problem! We then looked at what was being saved in the save routines- sure enough it was the old screen address and the old VBL address. We then kept an eye on that area of memory whilst running the "Present..." screen, and sure enough, that area of memory was being overwritten! The "Present..." PI3 file, at this point being unpacked to screen 1, was apparently overwriting this area!

But surely we had reserved enough memory *before* the start of screen for this not to happen? Well, not quite! Due to the fact that we wanted screens 1, 2 and 3 to display on screen, and as STFM video addresses have to align on a 256 byte boundry, we did a bit of a hack to determine the actual display addresses of the screens. First, we reserved 3 screen buffers worth of memory. eg

```
screen1: ds.b 32000
```

Then we added 256 bytes *before* the screen buffers. eg

```
         ds.b 256
screen1: ds.b 32000
```

Then we added address pointers to each of the screen buffers back in the data section of the code. eg

```
         data
         [...]
front:   dc.l screen1
         [...]
         bss
         [...]
         ds.b 256
screen1: ds.b 32000
```

Then, in our `init` subroutine, all we needed to do was clear the least significant byte of the address pointer. eg

```
         clr.b front+3
```

Since the maximum value of a byte is 255 (ie 256-1), any memory address ending in `00` is on a 256 byte boundry! And since we pre-padded the screen buffers with 256 bytes, that memory address shouldn't in theory overwrite anything before it, right?

**WRONG!!!** One thing we forgot to factor in was that we were depacking Degas PI3 files to *34 bytes before* the start of the screen buffer so that the bitmap itself would display at the *real* start of the screen display! Thanks to the 256 byte buffers before the screen buffers, normally, after the screen buffer pointers were aligned to 256 boundry addresses, there would be more than the 34 bytes of required before the screen buffer to unpack to. **BUT**! That's not guaranteed! What if the address pointer for screen 1 has been set to a 256 byte aligned address that's *less* than 34 bytes after where important data is stored? Unpacking a PI3 file to that screen buffer would overwrite that data! And *ole!*, that's exactly what was happening!

It's amazing to think that this bug was in the original demo, and it's only through sheer luck that we've just discovered it a quarter of a century later! By "luck", we worked out that, due to the 68000 needing to put code on even byte boundries, that there were 128 possible addresses per 256 byte boundry that the demo code could be loaded to, and that only *16* of those address would cause the bug to kick in, which means that most of the time, when it was loaded to an address that just happened to be in the 87.5% of "safe" addresses, you wouldn't see the bug. (Including that time it worked in HRDB)

Anyway, once we knew what we going on, it was easy to fix- all we had to do was change the 256 byte buffer for the first screen buffer to  `ds.b 256+34`, and at a mere cost of 34 bytes of memory (Still using less memory than the original!), the demo was working again!

### One last (nice!) suprise!

We'd fixed this bug shortly after we had uploaded [the source code for our patch to Reject's "Reject" demo](https://github.com/theseniordads/reject) to GitHub. Whilst we were working on that, we discovered that there was a modern packer called [UPX](https://upx.github.io/), which although designed for modern systems just happened to support old Atari programs, and appeared to be even more efficient than the mighty Atomik v3.5 packer!

Intrigued by this, we put our "remix" executable (182K) through UPX, and the result was... Just over 121K! (124,156 bytes to be exact.) The original 1998 release of the demo was... 124,666 bytes long! So our remix demo is 510 bytes smaller than the original!

So after all that rigamorle, we have a remix that contains more data, has a smaller memory footprint, and is a smaller file size than the original!

## Conclusion

And that is finally that: we've finally got a source code version of "Mono Mental"! And we've even got a tweaked version of it that is as close to what we intended the original demo to be like! From this epic journey, we learned the following lessons:

1. If you're using modern tools to develop for the Atari, use VASM, but make sure you have a way of automating the assembly and build process. Once we tweaked it a bit, AmigaAssembly was a godsend for us- everytime we saved, it would do a test assembly of the code, giving us and instant syntax check, and building an exectuable was as simple as pressing `CTRL+SHIFT+B`- no fiddling about with comand line gubbins!
2. If you're wanting to debug your code, a external debugger is extemely useful. In this case, HRDB was a vital tool in our debugging arsenal, and we couldn't have done it without it!
3. However, HRDB *couldn't* do everything, so don't be surprised if you have get down and dirty, and use good old MONST2 on the Atari platform itself. After getting reaquainted with it, we were impressed by how good a debugger it was for it's time!
4. Ripper programs can be useful for extracting data from a binary, but don't be surprised if you have to do some manual work to get the data you want!
5. Even with good disassemblers like TT Digger, there will be a lot of crap code left over from the disassembly process, so be prepared to do a lot of cleaning up! This will probably be the most time consuming part of the process.
6. As well as modern tools, you'll be using a lot of old tools on the Atari platform, so take advantage of the fact that can spin up multiple instances of Hatari in different modes for different tools, thus enabling you do to some multitasking!

We hope you've enjoyed this epic journey as much as we have! (For at least some of time!) We're not sure what we'll be doing next, but we'll need a lie down and some Horlicks first!

**SENIOR DADS RULEC!!!**

*Ended: 2023-09-12*

*Remix Ended: 2023-11-03*

*Shout out to:*

* Steven Tattersall- Great to see you on GitHub, and [HRDB](https://github.com/tattlemuss/hatari) is a quality tool!
* Sync- Just saw your entry [*Monism*](https://demozoo.org/productions/325847/) for Sommarhack 2023! Nice one! Amazing to see that 25 years after "Mono Mental", there's a [competition category](https://demozoo.org/parties/4490/#competition_18015) for mono demos!
