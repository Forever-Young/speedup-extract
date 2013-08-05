speedup-extract
===============

Speedup of mp3 files
--------------------
Place symlinks to original files into 'original' directory.
Tune speedup in 'SPEEDUP'.
Run 'speedup.sh'.
Run 'copy-back.sh' to copy resulting files to their original places.

Extraction of mp3 from mp4
--------------------------
Place mp4 files (or symlinks) into 'original' directory.

Run 'extract-speedup.sh' with parameters:
[speedup_rate] [original_dir]
or 
[original_dir] [speedup_rate]

'Original_dir' is 'original' by default.

For only extaction - specify '0' speedup rate.

© 2013 Anton Novosyolov <anton.novosyolov@gmail.com>
