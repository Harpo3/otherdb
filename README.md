# otherdb
A musicbase utility to copy last played values from an existing CSV-type database file
Requires kid3. Using the kid3-cli utility, scans all music file paths using the database FILE and checks each for existence of the frame name identified (default is Songs-DB_Custom1). If it does not exist, creates a TXXX frame with that name, then assigns the LastTimePlayed time value from the FILE to the tag frame.

Requires four positional arguments. Specify input database FILE, PATHCOL (FILE column number containing the track's file path), TIMECOL (FILE column number containing the last played date), and DELIM (database's field delimiter). The format of the TIMECOL field must be a numerical time value of either sql time or epoch time.
