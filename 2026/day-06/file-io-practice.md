## DAY 06 — File Read & Write

### What it is:
Practice creating, writing, appending, and reading text files.

### Key Commands:
```bash
touch notes.txt                 # create empty file
echo "Line 1" > notes.txt       # write to file (overwrites!)
echo "Line 2" >> notes.txt      # append to file
echo "Line 3" | tee -a notes.txt  # append + display on screen

cat notes.txt                   # read full file
head -2 notes.txt               # read first 2 lines
tail -2 notes.txt               # read last 2 lines
wc -l notes.txt                 # count lines in file
```

### Practice Output:
```
> creates/overwrites the file
>> appends to existing file
tee  writes to file AND shows on screen
```

### Remember:
- `>` = overwrite (dangerous! deletes old content)
- `>>` = append (safe, adds to end)
- `tee` = write to file + show output at same time

---
