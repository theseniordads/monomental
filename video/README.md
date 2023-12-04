# "Mono Mental" video capture

This section contains the videos of "Mono Mental" for the [Senior Dads Youtube Channel](https://www.youtube.com/@theseniordads).

## Video projects

* `monomental` - Original "Mono Mental" capture from the remix version of the demo running in Hatari as a 0.5MB Atari STFM on a monochrome display. Project uses [Open Shot video editor](https://www.openshot.org/) v3.1.
* `monomental_in_colour` - "Mono Mental" capture converted to colour. Project uses [Davinci Resolve 16](https://www.blackmagicdesign.com/products/davinciresolve) 16. Import the project file in the folder `project`. You may need to specifiy the locations of the source files. These are in the `src` folder.

### Extracting source video capture

The projects use the video file `monomental/src/mono_mental.mp4` as a source video. Due to the file size (204MB), this file has been split into 10MB chunks with filenames in the format `mono_mental.mp4.???`, and you will need to combine them to be able to use the projects.

The split files can be unsplit into one file using 7Zip on Windows. If you're in *nix, or have GNU command line tools (eg MacOs command line), the command `cat mono_mental.mp4* > mono_mental.mp4` from the directory `monomental/src` also works.
