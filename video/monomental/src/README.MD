# Extracting source video capture

Due to the file size (204MB), the file `mono_mental.mp4` has been split into 10MB chunks with filenames in the format `mono_mental.mp4.???`, and you will need to combine them to be able to use the projects.

The split files can be unsplit into one file using 7Zip on Windows. If you're in *nix, or have GNU command line tools (eg MacOs command line), the command `cat mono_mental.mp4* > mono_mental.mp4` from this directory  also works.